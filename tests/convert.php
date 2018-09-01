<?php

const TIC_MAP_WIDTH = 240;
const TIC_MAP_HEIGHT = 136;

const PICO_MAP_WIDTH = 128;
const PICO_MAP_HEIGHT = 32;

function tic80_map_file_to_p8($strMapFile, $strPicoFile)
{
    $strReturn = tic80_map_file_to_map($strMapFile);
    file_put_contents($strPicoFile, $strReturn);
}

function tic80_map_file_to_map($strMapFile)
{
    $objFile = fopen($strMapFile, "r");
    $i = 1;
    $intLine = 0;
    $arrData = [];
    $arrString = [];
    while (!feof($objFile)) {
        $strByte = fread($objFile, 1);
        $arrUnpack = unpack("H*", $strByte);
        $arrData[$intLine][] = $arrUnpack[1];
        $i++;
        if ($i > TIC_MAP_WIDTH) {
            $arrData[$intLine] = array_slice($arrData[$intLine], 0, PICO_MAP_WIDTH);
            $arrString[$intLine] = implode("", $arrData[$intLine]);
            $intLine++;
            if ($intLine == PICO_MAP_HEIGHT) {
                break;
            }
            $i=1;
        }
    }
    $strReturn = "";
    $blnActive = false;
    $intMax = count($arrData) - 1;
    for ($intLine = $intMax; $intLine >= 0; $intLine--) {
        if ($blnActive || (1 == preg_match('/[1-9a-f]/', $arrString[$intLine]))) {
            if (!$blnActive) {
               $blnActive = true;
            }
            $strReturn = $arrString[$intLine] . "\n" . $strReturn;
        }
    }
    $strReturn = "__map__\n" . $strReturn;
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
    if (!empty($strTable)) {
        file_put_contents($strTextFile, $strTable);
    }
}

function pico8_gff_to_table($strCode)
{
    $strReturn = "";
    if (preg_match('/__gff__([\n\r]([\da-f]+[\n\r+])+)/', $strCode, $arrMatches)) {
        $strReturn = "sprf={";
        $arrData = [];
        if (preg_match_all('/([\da-f]+)[\n\r]/', $arrMatches[1], $arrLines)) {
            foreach ($arrLines[1] as $i => $strLine) {
                for ($i=0; $i < strlen($strLine); $i+=2) {
                    $arrData[] = base_convert(substr($strLine, $i, 2), 16, 10);
                }
            }
        }
        $arrReverse = array_reverse($arrData);
        foreach ($arrReverse as $i => $intValue) {
            if ($intValue > 0) {
                break;
            }
            unset($arrReverse[$i]);
        }
        $arrData = array_reverse($arrReverse);
        $strReturn .= implode(",", $arrData);
        $strReturn .= "}";
    }

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
    tic80_map_file_to_p8($argv[1], $argv[1] . ".p8");
    exit(0);
}

exit("Invalid file name, \"{$argv[1]}\".");

