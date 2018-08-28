<?php



//$strPadding = str_repeat("0", 224);

/*
for sure, the cartridge consists of chunks, every has 4-byte header (1 byte - type, 3 bytes - size) and data

chunk types:
1 - tiles
2 - sprites
3- cover
4 - map
5 - code
9 - sfx
10 - waveforms
11 - music


$objFile = fopen("map.tic", "r");
fseek($objFile, 0);
$strType = fread($objFile, 1);
$strLength = fread($objFile, 3);
$x = unpack("H*", $strType);
print_r($x);
$x = unpack("H*", $strLength);
print_r($x);
$y = base_convert($x[1], 16, 10);
print_r($y);

fclose($objFile);
exit();

$x = file_get_contents("map.p8");
pico8_map_to_map_file($x, "map.data");

echo tic80_map_file_to_map("map.data");
exit;

$x = file_get_contents("map.p8");
pico8_map_to_map_file($x, "map.data");

$x = file_get_contents("flags.p8");
echo pico8_gff_to_table($x);
*/

const TIC_MAP_WIDTH = 240;
const TIC_MAP_HEIGHT = 136;

const PICO_MAP_WIDTH = 128;
const PICO_MAP_HEIGHT = 32;

function tic80_map_file_to_map($strMapFile)
{
    $strReturn = "__map__\n";
    $objFile = fopen($strMapFile, "r");
    $i=1;
    $intLine=0;
    $arrReturn = [];
    while (!feof($objFile)) {
        $strByte = fread($objFile, 1);
        $arrUnpack = unpack("H*", $strByte);
        $arrReturn[$intLine][] = $arrUnpack[1];
        $i++;
        if ($i > TIC_MAP_WIDTH) {
            $intLine++;
            $i=1;
        }
    }
    foreach ($arrReturn as $intLine => $arrData) {
        $arrReturn[$intLine] = array_slice($arrData, 0, PICO_MAP_WIDTH);
        $strLine = implode("",  $arrReturn[$intLine]);
        if (preg_match('/[1-9a-f]/', $strLine)) {
            $strReturn .= $strLine . "\n";
        }
    }
    return $strReturn;
}

function pico8_map_to_map_file($strCode, $strMapFile)
{
    if (preg_match('/__map__([\n\r]([\da-f]+[\n\r+])+)/', $strCode, $arrMatches)) {
        if (preg_match_all('/([\da-f]+)[\n\r]/', $arrMatches[1], $arrLines)) {
            $objFile = fopen($strMapFile, "w");
            foreach ($arrLines[1] as $i => $strLine) {
                $strLine = str_pad($strLine, TIC_MAP_WIDTH * 2, "0", STR_PAD_RIGHT);
                $arrBytes = str_split($strLine, 2);
                foreach ($arrBytes as $strByte) {
                    fwrite($objFile, pack("H*", $strByte));
                }
            }
            fclose($objFile);
        }
    }
}

function pico8_gff_to_text_file($strCode, $strTextFile)
{
    $strTable = pico8_gff_to_table($strCode);
    file_put_contents($strTextFile, $strTable);
}

function pico8_gff_to_table($strCode)
{
    $strReturn = "sprf={";
    $arrData = [];
    if (preg_match('/__gff__([\n\r]([\da-f]+[\n\r+])+)/', $strCode, $arrMatches)) {
        if (preg_match_all('/([\da-f]+)[\n\r]/', $arrMatches[1], $arrLines)) {
            foreach ($arrLines[1] as $i => $strLine) {
                for ($i=0; $i < strlen($strLine); $i+=2) {
                    $strValue = substr($strLine, $i, 2);
                    /*
                    if ($strValue != "00") {
                        $arrData[] = ($i + 1) . "=" . base_convert($strValue, 16, 10);
                    }
                    */
                    $arrData[] = base_convert($strValue, 16, 10);
                }
            }
        }
    }
    $strReturn .= implode(",", $arrData);
    $strReturn .= "}";
    return $strReturn;
}

if ($argc < 2) {
    exit("Please pass a file.\n\n");
}

if (preg_match('/^(.+)\.p8$/', $argv[1], $arrParts)) {
    $strCode = file_get_contents($argv[1]);
    pico8_gff_to_text_file($strCode, $argv[1] . ".gff");
    pico8_map_to_map_file($strCode, $argv[1] . ".map");
    exit(0);
}

if (preg_match('/^(.+)\.map$/', $argv[1], $arrParts)) {
    $strCode = tic80_map_file_to_map($argv[1]);
    file_put_contents($argv[1] . ".p8", $strCode);
    exit(0);
}

exit("Invalid file name \"{$argv[1]}\".");

