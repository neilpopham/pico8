pico-8 cartridge // http://www.pico-8.com
version 29
__lua__

-- fighter street ii
-- by bitwise creative
function _init()
  music(0)
  f = 0
  cartdata('bitwisecreative_fighter_street_ii')
  high_score = dget(0)
  menuitem(1, 'bgm on/off', bgm_toggle)
  b = {0, 1, 2, 3, 4, 5}
  palt(0, false)
  palt(1, true)
  floor = 72
  p1start = 15
  p2start = 98
  vscpu = true
  score = 0
  bgm = true
  kyu_frames = {b = '13.b18k3b9kj2k2b7gfpoejb5nghfe2ng2b3fo2nfap2g2pnbfepaf2pngnengbo3cgng3np2b2opghgnq7f2a2fnb7nhganhnb5fg2na2n2b5fh2ga2ghr4nh2gf2gh2b4nhg2bfgh2b4fgngb2ng2b5g3b2g3b5fhr2g2hb5epb3eob6opnb2opr10oq.q2fb:rfb', d = '27,50,13,14', db = '40,50,13,14', dh = '53,50,15,14', dk = '0,50,27,13', dp = '68,50,20,14', f = '15.b6kb15k4b8ghnj3k2b6np2g2p2ob7eo2gh2efpb6eprpnhopt4fp2ef2ageont3fe2cafgreoenqfg2nt3fqghnag2b8gnhf2hgnb7n3a2rht6rn3g2h2qfghgtrh3b4rhgb3nhgnb4r2b3r2hb4frnb3r2t4fg2t2ferqeot4opqep2qp2nqfob6fq.qb5:rng:sfb5:tfb', f1 = '18.b7kb17k2b16jb16jk3b12fgkockfpf4b4nh2nk2one2bcb5noph2p2onb9fopngno2f2b2ghgb3opog3n2f2ngnh2gbopeng3n7g3bepebngn3gh3n2ghb2fa2pofgng3hg3hb4fofbnfn3gh2eob13ng2epb13fg2opob14opeb16p2e.', f2 = '18.b13np2b17opfb9fpob3e2b11npof2pfb12ope2pfb10fepbg2hgb9fgeofg2hb10n2g2n4b10ng3fng2b10ng3hgngb5nefn2bfg3h2n2b2ok2pnepoafgngh2gbeobkeafn3f2g2n2fb3k2jpnh2nhnfnghb3epjn3g2h2g4b3cp2ep4ghg3hb5p3opo2ng3hfb8f7b7.', h1 = '16.b3kb12k3jbk2b2f2b6opnknfb2fpab5fn2pen2pfafb5epenp2ne2pb5gopon2egfefb5f2epohnf2b8nfpopef2o2b7nepeca2ofb8g3nfnhnb8fng2n2g2hb8ng2hn2gh2b8g2h2f2ghfb7fnh2bn2hgb7n2gnbfnh2nb6nghb3g3b8enb4fofb7o2b5opb7poeb4e3.', h2 = '15.b8k2b11k4b6npohgnpjkb5f2p2hgpjap2fb3nepfg2okne2pob2epfghgo2gbfceb2fopfefgb5p2bgn2afnbab4fef2nhgfafnb7ng2hng2hgb6fg2hgng2hgb6nh3bng3nb5fghgb2n2g2b5n4b3gngb5n4b4g2b6enb5epb5epnb6p2b5neob5ef2b2.', i1 = '13.b5k5b4nphnjkj2kb3fopfghpopkb3fo2ngf4pb3fep2of2efgb4ne2h3gfonb3ng5n3ob4f4af2oafb2ng2afnhfb5nhf3anfb5hnf2hfn2b4ghgnfh2g2b4h2gnbgh2gfb3hgnfbn2h2nb3g2nfb2fhgnfb2g2n2b3fg2nb2ngn2b4nhgfb2g2eb5gnb4pob6peb2epob5fp2fb10f2b.', i2 = '13.b6k3b5n2gnjk4b4epeghp2jb5epog2n4b4fp3fan2pb4noe2hgpnpb4fgh3gngefb4afg2f3oeb3fg2a2ghfafb3nh2afgnfb5hnfanagnb4nhg2fg4b4h2gnfnhg2fb3hgn2b2ghgnb3g2n2b2nh2nfb2gng2b3g4b2ngn2fb3nhgnb2g3b5gheb3epb6eob2eopb6p2eb10f3.', j1 = '13.b7nfnb6k4fnfb6k2jeb2cpfb2n2gnp2gfeopbnpnp3o2geo2bnpe2o2g2fe2b3non2hg2fb5fg5nb7f2qfnb7q2agn2g2nb3n3aq2qhnb2qnfqq3b3qfn2fg3fb3qhgbg2n2b4qhfoen2b5q2fpnb7g3fp2b7g2hbpfb7n2hb10peb10fp2b11p2b11f2b9.qng', j2 = '12.b4k5b6kj2ok2b4g2hgp2eb4n2p2ghenb4gepen2pf2b3np2eg2onpb3nepghnfepob3eopf2b2fanpfge2fngnb2ebng2nafpghgb2fg2ngogngh2b3n2gh2g3b3ng3n2gnb3ong2nbfb5pogpnb7p2b11efb9.', jk = '88,49,24,14', jp = '19.b26kb19k3b8p4og2jk2jkb7e4g5n2b11g5hnp2b9fn2g4oep2nfb6n2g4hefeop2fb5afnghg2nb3feaeob2fnghfn2g3b6e2bn7g3qfg3h2g2b11pfng3hfb11ongn2ghnb12g3n2fq.qb10', ko = '91,0,29,7', m = '12.rkb11k5rnhgj2k2jkb2nepfhpnpkb3nopfg2ofgfb2eo2nghgpnpb2op2f3noepebe3af2g2fcenbafngn2b3fb2ng2afgb5fghga2h2b5ghna2ghb5ghgafghnb3fh2gfngh2b3fhg2b2g2hnb3g2nfbng2fb3fhgb2g2hfre2b2egqfpob2epb6opb2epob9fq.q2b4:rb4', p1 = '15,64,12,7', p2 = '27,64,14,7', p3 = '41,64,13,6', ph = '54,64,10,12', s11 = '19.b7k4r6kjk3r2og2okjkr2n2oeng2r2gp2g3pnr0on2hgnp2ob9fefngqonr0eafpepogr0fg2foponr1n2hf2gnhnr0gafangnh4fb7gfan2g6hb6fh3nb2fn3ghnb4fgh2gb6nh2gb3fhg3b7fghgfb2eg3b9ngeb2eongr1fpnbfo2nr2q.qep2:rb1', s12 = '24.q4k4q7fn2kok2q6ngp2gnpk2b3f2q0gop5jkpefeq1neofo3p3eafq1g2og3onoeanoq1g4h2grfeq0gn2g3nb6fb9nhg2a2fgfq4ngnhgf3g2h2gq0ngh2g2anfng4nb8g2h2gfbaf2n2g3fb6ng4nb7ng3b6fg4nb8nghgb5peg2nq0feb6epoq3opb6eoeq3oep2r.qb1:rfb3', s21 = '14.b6k2b12jkb13k5b7ghgjk2jb5nfnhgnpnb6eopng2ognb5fo2nopon3b4oeof3ogconb3fp2f2gqfb5fna2ngb7nf3g4b6g2hgfg2h2b5g2hgfn2gh2b4hghnbfng2hgrngh2fbfn3gfbg2nhgrn4roegnfb3engb3p2fb4fpob4e3b5fo2q.qfb2:rb2', s22 = '13.b7fpb11nfnb11afb11e2fb10op2b10kopb8k3p2b7k4p2b8jkngob6nkoghgfb2enfgnhohghfb2af2p2g2hg2b3aepo2ghg3b3oepofg5b4pebng2n2gnb6g2fnhg2hb5n2hg2n2g2b3fg2nfng4b3fg3opeg2b4fg2nepfgb5nhgfopfb6g3fefb7ghgfb9goeb10fonb10fob11opb8.', s23 = '11.fnob8feob9f2b9epb5k2b2opbk3bjkb2oepjk4b3eogn2ejb5fgfon2q4gp2g2h2b4gegh2npnb3fnghep2nb3angnfopb5nfneopq4a2opo2b4ngn2epnb3ghgn2g3b3hgn3ghgb2fgn2bfghgb3n2g2bghgq3ng2bng3b4nepbnghq3e2b2ng2eb3epb3nepb4ob4oeb8eonb9q.qfb', s31 = '12.b4k4b8jkjb8n2g2opfb3ngng3eop2b2ngng3e2opobn3g5bfb3ngng4b6nfa2fb4o2n7gnb2fgn2g3nb5n3gn2b5fn4b7g3nb8nghgb8g4b8gng2b10o2b9fp2b8foeb10fb9.', s32 = '21.b6kq9k4q8jk3q4openjfq3ep3ohgbfq2eoefeg2of2nb9p3f2pghnaepq0f2a2fohnbfq1n3f3nfq3n2hgngh7gb5pf3n2g12n2pfb3n9g4fopfb4n5b7fb8fn4q7ngngq7ng3q6fg3fq6ng3q7fn3q7peq9opq9opq6.qb1:rb16', s33 = '12.b5k2b9k2jb8ne3ghnb3fgn2fn3opbopgonfg2np2bfpgeoaepopeb2enengep3b5f2afgn2b4g2ng2hgb5fn4gnopnb3n4eoe2ob4n4phb8fn2g2b8ng2hb8n2g2b8ng2hb8ng2hb8cob10opb10fpeb11ob2.', s34 = '21.q3kq8k4q8ojkq7efp2hg2q2eopo4hgpfq0p2e3og3npq2fn2g5oq3n4g3b2pfb5n3fngng2n2b3np2oh2g2h2g3n2g3f3b2f2g3n2g3n2ghg2q5fghg2q6fg3fq6fng2q8ng2nq7g4q7fngeq9fpnq8fpq9opb4.qb1', sb = '13.b5k3b8njk4b5n2ghp2jb6epeg2n3fb4epopfpnp2fb4fp2ehgnp2eb3noeh2gbfofb3fghg2fbpab3fgafaghb6nh2afgnfb5hnfanagnb4nhg2fg4b4h2gnfnhg2fb3hgn2b2ghgnb3g2n2b2nh2nfb2gng2b3g4b2ngn2fb3nhgnb2g3b5gheb3epb6eob2eopb6p2eb10f3.', sk = '91,7,26,21', sp = '93,28,24,21', u1 = '12.b3no2nb10epefb8epfp2b6ne2bpeb5n2fo2p2b4ngnp2ef2b3fg2n4ghfb3gn2g3h3fb3fng2h3g2bnb3ang2hn2p3fgnfgfn2gpopon2g4n2pkeponhg3fbk3opeg2n2b2k2j3n2fb4.', u2 = '18.b4o2fn2b9ponb2g3ngn2f2b5eobng2n2g4fb6eg3fgng2h2ghb5ng3n2g4h2gnb3fn2h2nfnpnhgn2gb4fnghnbnpog2k3b5nhgb2opf3k4b9p2b3okjkb9p2b2fopbk2b8epb2feobjb10nb3afb11afb3afb11nfpbf3b11fnb3nb4.'}
  kyu_fix = 'i1 0 0 0,i2 0 0 0,h1 -4 1 1,h2 -1 0 -1,f1 -6 0 1,f2 -8 2 3,ko -8 13 -7,u1 -3 5 4,u2 -3 3 -2,sp 1 0 -12,sk -5 -1 -8,d 0 7 0,dh -3 6 1,dp 0 7 -7,dk 0 7 -14,m 0 0 1,f 2 0 -4,b -2 0 2,j1 -1 -3 1,j2 0 -3 1,jp 0 -3 -6,jk 0 -3 -11,s11 0 2 -6,s12 0 3 -11,s21 0 1 -1,s22 0 -8 0,s23 0 -8 2,s31 -1 -3 2,s32 -1 -4 -7,s33 -1 -3 2,s34 -8 -4 0,p1 17 4 -16,p2 16 4 -17,p3 17 5 -17,ph 21 2 -18,sb 0 0 0,db 0 7 0'
  kyu_anims_base = 'i:i1 10 0,i2 10 0|j:j1 8 0,j2 999 0|f:m 5 0,f 5 0,i1 5 0|b:m 5 0,b 5 0,i1 5 0|d:d 1 0|sk:sk 6 5|sp:sp 6 5|dk:dk 6 5|dp:dp 6 5|jk:jk 10 5|jp:jp 10 5'
  kyu_anims_supers = '|su1:s11 5 1,s12 10 4|su2:s21 3 10,s22 6 10,s23 5 10|su3:s31 2 5,s32 2 10,s33 2 5,s34 2 2,s31 2 5,s32 2 10,s33 2 5,s34 2 2'
  kyu_anims_bh = '|db:db 6 -1|sb:sb 6 -1|dh:dh 8 -1|h1:h1 8 -1|h2:h2 8 -1|fall:f1 5 -1,f2 5 -1,ko 5 -1,u1 5 -1,u2 5 -1|ko:f1 5 -1,f2 5 -1,ko 999 -1'
  kyu_anims_ult = '|ult:s31 1 12,s32 1 12,s33 1 12,s34 1 12,s31 1 12,s32 1 12,s33 1 12,s34 1 12,s31 1 12,s32 1 12,s33 1 12,s34 1 12'
  kyu_anims = kyu_anims_base .. kyu_anims_supers .. kyu_anims_bh .. kyu_anims_ult
  kyu_supers = 'udbdbk.3.12.-3.199,2fdfp.1.3.-6.0,1dfp.0.0.0.135,3dbk.2.6.-3.0'
  kyu_shadow = false
  chi_frames = {b = '12.b6c3b8cic3b7c2oecb5fgc2pfb6fpc2nb7gocghb2nfb3pf2gnfc2fb3ofef2pecb3fecfb2eb4coec2b7cohecb8cp2ecb6c3o2fb6c4e2b7c3neb7ce2pfb7nefeb7ngbn2b6fhb2nhb7n2bnhnb10f2b5.', d = '11.b5c3b7cic2b7c2pcb5cnc2pb6foc3b6npgcnb2ofb2gon4fcb3nhf2epecb3cefecfe2fb2ecnc2e3b2cpofcece2b2fcpefc2fnbn2cepob2gnbhfe2oeb2gb2gnbcb4gnb10fb.', db = '10.b4c3b6cic2b6c2pfpb3cnc2pnpb3foc3n2b3npgcn2pb3gonp3fb3nhf2enecb3cefecfe2b2ecnc2e3bcpofcece2bfcpefc2fn3cepob2gnhfe2oeb2gbgnbcb4gnb9f.', dh = '12.b3c2b8c3peb7c2icn2c2b4c4nponb3c3bg2nphfb6g2nfnb7nhnfnb7cf2epecb5efecfe2b4cpnc2e3b4fcpcece2b3n2cepc2fn2b2hfe2oeb2gb3gnbcb4gn.', dk = '21.b11cfqfnfceb2fbngnb3c2bhnp3nfneo3g2nb2c4hge5onf3b5c2en3c2nc3b9c2pfgpncn2cb9c2ichgn2e3fghnb5c2b2nhgfce3n4b9onb2cp2onb12pfb2n2fb14ofb2nc2b13fpfb18npb19feb19fb20eq.qb17', dp = '20.b8c4b16c5b14c2iec2b13cgc2pnb15ncn5fnfcnfb6fecghgp5fefb5fec2g2b4fbfb7fenhncb15cngb16gencf2eb12npen2e2ofb11epen2ce2b11foefgcfofb8ngo3ehfcgnb9nhepcb3fhb10fnb7gnb9.', f = '13.b8c2b10cic2b9c2ecb7n2c2pfb7phc2nb7npgchnb6fpfnhgncfeb3fnfn2e2nc2b4cfncbnpb5fefcb9fp2c2b8fep2eb8c2ep2eb7c4e3b6c2ec2e2b6e2cb2ofb5nefb3efb4ngb5n2b3fgb6hnb3fgnb5g2b4fb6fnfb2.', f1 = '20.b4fn2q6cehpq4cicng2nq3c2nh2g2fefq0c3ng2n2phefb7c4fgfchnp2ecb6c3b2nb2hnehecb7cb6cne2oe2q3cn2fpe2fq3cfcpe2ocq5p2cngq5fpfbg2q5ngb2hgfq4gnbf2q6hnq8ngb3.qb1', f2 = '17.q2nebfq3n2bcfq2gpf2q2nhbneq1fgfcgfq0fhncofq0foefe2cq0noc2efq1epfe2q2opcofq1fopcefcb6icnfp2oc4b5c2ngechpcfnb5c3p2gnp2n2b6c6nb9c2q5.qb1:rfb1', h1 = '18.b4c3q3c4peq2c3icn2c2b8c6nponb7c3b3g2nphfq1cg2nfnq3cnhnq5ngnq5cn2q4fon2cq3ehen2cq2cepegnfq1fce2ceoq1fncpecefq1cfpebceq2eofbcefq1oeb3e2q0ngb4cgnb9n2b5hgb9gnb6g2b8n2b7nf.qb1', h2 = '11.b4c2b7c5b6cbc4b7nc4b4cngc4b4nphcicb4nhefgncbfecopc2n2efnefpecfcbp2fbfphecqb2fcp2fceb4fc2epfceb4fc2enceb5fcefcefb5fofbe2b6efbfnb6nb3gb6nb3n2b4ngb3nhnb4gnbq.q3f2', i1 = '11.b4c2b8cic2b7c2pcb6nc2pb6foc2fb6fpcgcb2efb2nonhnf2efb2ghf2epecb3fnfnf2b4fecnc2b5foen2cb6cpececb5ce2c2ecb3fc2e2c2eb3fc2peb2ecb3ceocb2e2b3fofb3fnb3n2b5hnb2gb6ngb2hb7gnbfb8f.', i2 = '11.b4c2b8cic2b7c2pcb5cnc2pb6npc2fb6g2cgcb2fb3gng2nfneb3p2f2epecb3fefnf2b5fcfcb6foenfcb5cepf2c2b5coece2cb4c2efc2eb3fc2eob2efb3cfpfb2efb4oeb3e2b3nob4cnb3gb6hnbfhb6nhnbgfb6fn.', j1 = '9.q4b5cic3q2ofc2q2ghgq3phq2ng2nqb2gncb6fn2eb5fn2fb4fe2cb5epefcb3fepofcfqepce2b2f2e2fcofbfnfefbe2b2cnob2efb2fonbe2b3fpfbnfb4ofbgb5efgnb5nbn2b5gbfnb4fgb8nb8f2b4.qb3c', j2 = '10.b2c6b3c5ic2b3cn2cepcb4pghnob4pn2g2nb3ghf2g2fb3fofnfnfb3fe2c3b4ep2ec2ecbfce2p2ceof2cfe3ce2f2ngfn2f2b2fn2cgfb5n2cnb7fncb5.', jk = '20.b5cb18c3b16cic3b13c4pfcnqc5n2hg3n2bcb5cb2fhng2cnpopfefb8nghpcfpec2nfb9n4e2pef2b10fc2n2ceop3fb8f2cf2c3bfeoghfb3nghne3cb4cb2g2b4g2ne2pg2hgb5nb5fnpopn2bgnb12f2q.qb11', jp = '17.b11cb16c4b14c4b10fpgnc4b8fcgn2c2eib8efcfhncpcb7c2fchg2cfcrchg2en2phcrch2phpecbnf2b5n2c2op2obcecrcefce2o2fcb2nb4coecbep2eb3hgncefefbg2efb3fgb2e3c2hqfnb4cb2fq.qgb6:rb6', ko = '21.b9ceocb9cbfgnb2fo2eofb7c2ig3c2p2ecencb6c3pgncp2ec3gncfb3nc3fec2oec2jecg2cg2nec8fc5nhn3fb3cfpfb6cb3fb7fofb15.', m = '12.b7c2b9cic2b8c2ocb7c2p2b7fc3fb7fcghb2nfqnpn2bcefqnhf2pecqe2nf2eb5npfc3b6npec2b7fepc2fb6c2pc2eb6c2e2cefb6ce2cefb6eocfeb6cefbe2b5ngfb2nb6gqgb5fhnb3hnb5fnb3fnq.qb4', p1 = '9,72,6,4', p2 = '15,71,9,4', p3 = '25,71,7,4', ph = '32,71,8,10', s11 = '21.b4c3q8cic2q6c2epcq5c3n2cq4c4ng2fb7ng2nbc4nhgn2fb3f2ghg2nbcbnpfngf2c3e2f2ghgnb3fs2gnc3e5g3hnb6chnc3e2n2g4nb5fcnfcsfs2ngnb6ncf2c2q5fc2e2c2q5c2pc2fq5cfec2q7fecq8foq9e2q9n2q9g2q9n2q9gnq9nfq3.qb1:r2b1:s2b:tb19', s12 = '21.b4cq8c4q7ciecq6c3pfq5c3fn3q4cpfngnofq3cpng2n2pb9ng2nbf2ngncefb7cgh2nb3cghfec2q5fhfce2cq3fcfc2e3q2fc2fc4efb5ghgnb2fc2fec2e2fb5gh2nb3c2necfhgq4ce2cnq7efq9ofq8cefq8cnfq9gb20nb20hb20nq5.qb1:rb15:sfb1', s13 = '17.b4rs4c4s2riecs1cpcnpcqc4ng2nqf2ng3nqnpengf2ofcb7fnb2gnrecs1nhc4eb9fcnrerb8nrfre2cn2hb5nrfereoeg3b5rperfopfnhnb4rorb2copgnb6fecb5ghgb6fob6nghnb5e2cb6ghgb5feb8nb6g2s5n2s5gns5n2q.qb10:rc2:sb1', s21 = '13.b5c3b9c2ic2b8c3ob9c3pb9c3b10ncgfefb7npcepb8npf3b7fenfcb7fpenfc2b6fpen2e2cb4c2oecfeo2fb3c2eocbc2feb3c2opcb3fob4epfb5eb4peb6nfb2nob7gnb2gnb7ghbg2b8npn3b11.', s22 = '15.b8c2b12cic2b11c2ecb10c3pb11c2nfb10c2g2fb4fb5cng2pfbce2b6g2cep2fcnb6gnb2fnc2b6cn2cb10nen2ce2fb6np2n2eo3fb4fce2nfce4b5copc2b3fofb4npecb4fofb3fpecfb5n2b3g2b8ngb2ngb10hn2hb11n4b13.', s31 = '23.b9c3q9cic3q6c4pc2q4c6pc3q7n2fc2fq7npnhnfq8npgcq6npnbnoc2q5n3c2nc2q5n2c4hnq6hcnpc4q5c2ehp2efb9fnbcefe2cop3o2efb6phnce3fcf3ef2ponb2nfngq4f2nghgbnq9gfb.qb1', s32 = '9.b3c4b5c3b5c4b3fghc3hb2fohnc2gnb4gc3pb4cn2cefb2c5b4c5b4echnc2b2c2ec2efb3nefcofb2nhgc4b2egncbcb3enb7pnb6.', s33 = '22.q1cb20c6q6cecic3q4ncnpc3q4cecfnq8fncnpnq6fngpnq7cepnb2nq5cfncn3q4n2hnc3nq4n2c2echnq4c2ep2fcq3feop2hpcfcbcb8fo2eo2e2c2oeoechgbngn3pfc2fc3bf5nhnbhgnq7n.qb1:rnb1', s34 = '8.b3cb6c4b4c3b4c4b3nc4n2bfc2nhfeb3gfnp2fbfofngnb3cnfb4fc3fb3fecfcb3e2fe2b3c3epfb3cbfheb2nhb2nfb6f2b.', sb = '12.b5c3b8c5b7cie2cb6fc2pncfpr3nc2nfncpnb4pcnfocb6gcgfcpb6ngp3b7encb8nenfcb6fpon2cr5fnpnfecb4fcnenfcoeb4coef2ce2fb3fpcr2cefb3pecb3fecb2fpfb4feb3feb5nfb3gnb5gb3ngb6gb3gnb6ngfbq7q.qf2b:r2b', sk = '17.b3c3q3cic3q1c3gecb9nc4pfb6cfg3bnc2n3b4fo2gb2fpnh2n2gcfeo2fb4efg2nfe2p2fb8cgnceoecq0nhnc3f2b9fnhfcbnfb8ncf2c2q0fc2fec2q1c2fec2q2ce2c2q2ce2cq4ofq5efq4cefq5gnq5gnq5gnq5gfq0.qb1:rb10', sp = '22.q0c3q8cic3q5c4oecq3c5fpfq7g2ncng2n2gf2nb9ng2hgnpgphfepfb8p2g2nb6fb9f3ncq7fefgnq7c2fhfc2q3ncfenhece3q0nc2pohfe6q0ceonhc6eq0npehcfb3ce2b9npec2fb5enb8gofb2fb6n2b6nhgq1ngb5nhnq2fhnb20fnb4.qb1', u1 = '16.b3c3b13cic2b11c3pcb11c3ncb10c2gcgnfb3cb6nochnpnce2fb5pn3f2ce4b5pfcepfcec2eb4npc2e2pc2b2g2b3n2c2ecegnb3gnbc5ec2ghnc2ghn2pcb2c3b8eob14.'}
  chi_fix = 'i1 0 0 2,i2 0 0 2,h1 -7 0 2,h2 -1 0 3,f1 -7 0 0,f2 -8 0 4,ko -8 14 0,u1 -3 8 0,sp 0 1 -9,sk 0 -2 -4,d 0 5 2,dh -2 6 3,dp 0 5 -7,dk 0 5 -8,m 0 0 1,f 0 0 0,b 0 0 1,j1 0 -6 4,j2 0 -3 3,jp 0 -3 -4,jk 0 -3 -7,s11 -1 -1 -7,s12 1 -2 -9,s13 0 -1 -4,s21 0 0 0,s22 0 0 -2,s31 -6 -5 -4,s32 0 -5 4,s33 -7 -6 -2,s34 1 -6 4,p1 12 5 -5,p2 10 5 -5,p3 9 5 -5,ph 10 3 -5,sb 0 0 1,db 0 5 3'
  chi_anims_base = 'i:i1 12 0,i2 12 0|j:j1 8 0,j2 99 0|f:m 5 0,b 5 0,i1 5 0|b:m 5 0,f 5 0,i1 5 0|d:d 1 0|sk:sk 6 5|sp:sp 6 5|dk:dk 6 5|dp:dp 6 5|jk:jk 10 5|jp:jp 10 5'
  chi_anims_supers = '|su1:s11 5 5,s12 5 5,s13 5 5|su2:s21 5 1,s22 10 4|su3:s31 2 5,s32 2 10,s33 2 5,s34 2 2,s31 2 5,s32 2 10,s33 2 5,s34 2 2'
  chi_anims_bh = '|db:db 6 -1|sb:sb 6 -1|dh:dh 8 -1|h1:h1 8 -1|h2:h2 8 -1|fall:f1 5 -1,f2 5 -1,ko 5 -1,u1 6 -1|ko:f1 5 -1,f2 5 -1,ko 999 -1'
  chi_anims_ult = '|ult:s11 2 14,s12 2 14,s13 2 14,s11 2 14,s12 2 14,s13 2 14'
  chi_anims = chi_anims_base .. chi_anims_supers .. chi_anims_bh .. chi_anims_ult
  chi_supers = 'udfdfk.3.14.-2.0,3dbk.7.0.-6.0,2dbp.8.0.0.154,1dfk.9.3.0.0'
  chi_shadow = '5,2'
  sol_frames = kyu_frames
  sol_fix = kyu_fix
  sol_anims_supers = '|su1:s11 5 1,s12 10 4|su2:s21 2 10,s22 3 10,s23 3 10,s22 3 10,s23 3 10|su3:s31 2 5,s32 2 10,s33 2 5,s34 2 2,s31 2 5,s32 2 10,s33 2 5,s34 2 2'
  sol_anims_ult = '|ult:s21 1 12,s22 1 12,s23 1 12,s22 1 12,s23 1 12,s22 1 12,s23 1 12,s22 1 12,s23 1 12,s22 1 12,s23 1 12,s21 1 12'
  sol_anims = kyu_anims_base .. sol_anims_supers .. kyu_anims_bh .. sol_anims_ult
  sol_supers = 'udfdfp.6.12.-3.0,2fdfp.6.6.-3.0,1dfp.6.0.0.126,3dbk.6.0.-6.0'
  sol_shadow = '5,0|6,0|7,0|13,0|4,2|9,2|10,0|14,8|15,8|12,8'
  lua_frames = chi_frames
  lua_fix = chi_fix
  lua_anims_supers = '|su1:s11 5 5,s12 5 5,s13 5 5|su2:s21 5 1,s22 10 4|su3:s31 3 5,s32 3 10,s33 3 5,s34 3 2'
  lua_anims_ult = '|ult:s31 1 14,s32 1 14,s33 1 14,s34 1 14,s31 1 14,s32 1 14,s33 1 14,s34 1 14,s31 1 14,s32 1 14,s33 1 14,s34 1 14'
  lua_anims = chi_anims_base .. lua_anims_supers .. chi_anims_bh .. lua_anims_ult
  lua_supers = 'udfdfk.3.14.-2.0,1dbk.9.0.-5.0,2dbp.8.0.0.173,3dfk.7.6.-3.0'
  lua_shadow = '2,12|8,12|15,7|4,7|14,7|5,12|13,12'
  chars = {{name = 'kYU', avt = 136, frames = kyu_frames, fix = kyu_fix, anims = kyu_anims, supers = kyu_supers, shadow = kyu_shadow, winm = {'attack me if you must...', 'i will smash you!!'}, sp = 1, sf = 3, su = 2}, {name = 'cHI', avt = 140, frames = chi_frames, fix = chi_fix, anims = chi_anims, supers = chi_supers, shadow = chi_shadow, winm = {'i am the toughest lady', 'on the planet!'}, sp = 2, sf = 1, su = 3}, {name = 'sOL', avt = 200, frames = sol_frames, fix = sol_fix, anims = sol_anims, supers = sol_supers, shadow = sol_shadow, winm = {'huehuehue!!1', ''}, sp = 1, sf = 2, su = 3}, {name = 'lUA', avt = 204, frames = lua_frames, fix = lua_fix, anims = lua_anims, supers = lua_supers, shadow = lua_shadow, winm = {'opponent:destroy() -- ^^', ''}, sp = 2, sf = 3, su = 1}}
  ford = {{2, 4, 3}, {1, 3, 4}, {4, 2, 1}, {3, 1, 2}}
  curopp = 1
  p1 = false
  p2 = false
  players = {p1, p2}
  rt = 60
  rtd = rt
  pause = false
  ultanim = false
  slowmo = false
  roundn = {1, f, t(), false, false}
  draw = false
  clouds = sint_table('5,87,13,5|19,85,18,7|39,79,24,12|0,93,33,6|34,93,28,6')
  shuffle(clouds)
  numclouds = rint(1, 5)
  cloudpos = {}
  for a = 1, numclouds do
    add(cloudpos, {rint(-10, 127), rint(-3, 50)})
  end
  mountains = sint_table('0,115,64,13|0,99,64,16')
  screen = 'main'
  screen_conf = {}
  screen_conf.main = {logloc = -78, optloc = 78}
  screen_conf.charselect = {}
  screen_conf.vs = {vsloc = {-100, 300}, bg = {}}
end


function _update()
  f = f + .0001
  if f > 32000 then
    f = 0
  end
  if screen ~= 'fight' then
    return
  end
  if roundn[2] then
    pause = true
  end
  if p1.anim[1] == 'ko' or p2.anim[1] == 'ko' then
    if not roundn[5] then
      if p1.anim[1] == 'ko' and p2.anim[1] == 'ko' then
        draw = true
      end
      local d = p1
      if draw and p2.y < p1.y or p2.anim[1] == 'ko' then
        d = p2
      end
      local e = d.anims[d.anim[1]][d.anim[2]]['frame']
      if e == 'ko' then
        pause = true
        roundn[4] = 0
        if d.pn == 0 then
          roundn[4] = 1
        end
        roundn[5] = f
      end
    end
  end
  if slowmo then
    if flr(f * 10000) % 4 ~= 3 then
      return
    end
  end
  if not pause and screen == 'fight' then
    rtd = rt - flr(t() - roundn[3])
    if rtd < 1 then
      if p1.h == p2.h then
        p1:setanim('ko')
        p2:setanim('ko')
      else
        if p1.h > p2.h then
          p2:setanim('ko')
        else
          p1:setanim('ko')
        end
      end
    end
  end
  if p1.side == 0 and p1.x > p2.x + 4 then
    p1.side = 1
    p2.side = 0
  elseif p2.side == 0 and p2.x > p1.x + 4 then
    p2.side = 1
    p1.side = 0
  end
  if ultanim then
    pause = true
  end
  if pause then
    return
  end
  hit_testing()
  if p1.anim[1] == 'ko' or p2.anim[1] == 'ko' then
    slowmo = true
  end
  p1:update()
  p2:update()
end


function _draw()
  if screen == 'main' then
    draw_main()
    return
  end
  if screen == 'charselect' then
    draw_charselect()
    return
  end
  if screen == 'vs' then
    draw_vs()
    return
  end
  if screen == 'gameover' then
    draw_gameover()
    return
  end
  if screen == 'wingame' then
    draw_wingame()
    return
  end
  cls(1)
  local g = {{70, 12}, {6, 5}, {5, 3}, {3, 6}, {1, 0}, {20, 5}, {8, 6}, {1, 5}, {13, 3}}
  local h = 0
  for a = 1, #g do
    rectfill(0, h, 128, g[a][1] + h, g[a][2])
    h = h + g[a][1]
  end
  gfx_chunk(0, 57, mountains[1][1], mountains[1][2], mountains[1][3], mountains[1][4])
  gfx_chunk(64, 54, mountains[2][1], mountains[2][2], mountains[2][3], mountains[2][4])
  for a = 1, #cloudpos do
    gfx_chunk(cloudpos[a][1], cloudpos[a][2], clouds[a][1], clouds[a][2], clouds[a][3], clouds[a][4])
  end
  if roundn[2] then
    local i = ceil((f - roundn[2]) * 10000)
    if i < 20 then
      print_outline('round ' .. roundn[1], 50, 30, 8, 10)
    else
      print_outline('fight!', 52, 30, 8, 10)
    end
    if i > 40 then
      roundn[2] = false
      roundn[3] = t()
      pause = false
    end
  end
  if roundn[4] then
    if rtd < 1 then
      print_outline('time is up', 45, 20, 8, 10)
    end
    local j = false
    if draw then
      print_outline('draw', 57, 30, 8, 10)
    else
      j = p1
      if roundn[4] == 1 then
        j = p2
      end
      print_outline(j.name .. ' wins!', 48, 30, 8, 10)
    end
    local k = ceil((f - roundn[5]) * 10000)
    if k > 50 then
      if j then
        j.rwon = j.rwon + 1
      end
      new_round()
    end
  end
  print_outline(p1.name, 3, 11, 8, 10)
  rectfill(2, 2, 58, 7, 10)
  if p1.h < p1.mh then
    local l = mid(0, p1.mh - p1.h + 1, 58)
    rectfill(2, 2, l, 7, 8)
  end
  print_outline(p2.name, 114, 11, 8, 10)
  rectfill(69, 2, 125, 7, 10)
  if p2.h < p2.mh then
    local m = mid(69, 126 - (p2.mh - p2.h), 125)
    rectfill(m, 2, 125, 7, 8)
  end
  local n = {10, 15}
  rectfill(2, 122, 58, 125, 0)
  local o = mid(2, p1.ub + 2, 58)
  if o > 2 then
    for p = 122, 125 do
      for q = 2, o do
        pset(q, p, n[rint(1, #n)])
      end
    end
  end
  if p1.ub >= p1.mh then
    rect(1, 121, 59, 126, 7)
  end
  rectfill(69, 122, 125, 125, 0)
  local r = mid(69, 125 - p2.ub, 125)
  if r < 125 then
    for p = 122, 125 do
      for q = 125, r, -1 do
        pset(q, p, n[rint(1, #n)])
      end
    end
  end
  if p2.ub >= p2.mh then
    rect(68, 121, 126, 126, 7)
  end
  local s = 144
  local u = 9
  local v = {58, 10}
  if p1.rwon > 0 then
    for a = 1, p1.rwon do
      local w = (0 - u) * a
      local x = v[1] + w
      spr(s, x, 10)
    end
  end
  if p2.rwon > 0 then
    for a = 1, p2.rwon do
      local w = u * a + 4
      local x = v[1] + w
      spr(s, x, 10)
    end
  end
  local y = tostr(rtd)
  if rtd < 10 then
    y = '0' .. y
  end
  y = split(y)
  print_outline(y[1], 60, 11, 8, 10)
  print_outline(y[2], 65, 11, 8, 10)
  rectfill(59, 2, 68, 7, 0)
  print('K', 60, 2, 8)
  print('O', 65, 2, 8)
  if vscpu then
    local z = tostr(score)
    if score > 0 then
      z = z .. '00'
    end
    print_outline(z, 126 - #z * 4, 111, 8, 10)
  end
  if ultanim then
    local A = ceil((f - ultanim[2]) * 10000)
    local B = p1
    if ultanim[1] == 1 then
      B = p2
    end
    for p = 0, 128, 2 do
      line(0, p, 128, p, 0)
    end
    circ(B.x + 5, B.y + 5, 20 - A * 4, 7)
    if 20 - A * 4 < 1 then
      rectfill(B.x + 5 - A * 7, B.y + 4, B.x + 5 + A * 7, B.y + 6, 7)
      if A > 10 then
        B:setanim('ult', true)
        ultanim = false
        pause = false
      end
    end
  end
  p1:draw()
  p2:draw()
end


function bgm_toggle()
  if bgm then
    music(-1)
    bgm = false
  else
    if screen ~= 'fight' then
      music(0)
    else
      music(2)
    end
    bgm = true
  end
end


function split(C, D)
  local t = {}
  local E = ''
  if D == '' then
    D = nil
  end
  for a = 1, #C do
    local c = sub(C, a, a)
    if D == nil then
      add(t, c)
    else
      if c == D then
        add(t, E)
        E = ''
      else
        E = E .. c
      end
    end
  end
  if E ~= '' then
    add(t, E)
  end
  return t
end


function in_array(F, G)
  if type(G) ~= 'table' then
    return false
  end
  for a = 1, #G do
    if F == G[a] then
      return a
    end
  end
  return false
end


function tms2table(H)
  local c = split('abcdefghijklmnop')
  local I = split(H, '.')
  local q = tonum(I[1])
  local J = split(I[2])
  local K = {}
  if I[3] ~= nil then
    K = split(I[3], ':')
  end
  local t = {}
  for a = 1, #K do
    local f = sub(K[a], 1, 1)
    local L = sub(K[a], 2, #K[a])
    for M = 1, #J do
      if J[M] == f then
        J[M] = L
      end
    end
  end
  local N = ''
  local O = ''
  local P = {}
  local I = {}
  for a = 1, #J do
    if #J[a] > 1 then
      I = split(J[a])
    else
      I = {J[a]}
    end
    for M = 1, #I do
      if a == 1 and M == 1 then
        N = I[M]
      else
        if in_array(I[M], c) ~= false then
          if O == '' then
            O = '1'
          end
          for Q = 1, tonum(O) do
            add(P, in_array(N, c) - 1)
            if #P == q then
              add(t, P)
              P = {}
            end
          end
          N = I[M]
          O = ''
        else
          O = O .. I[M]
        end
      end
    end
  end
  if O == '' then
    O = '1'
  end
  for Q = 1, tonum(O) do
    add(P, in_array(N, c) - 1)
  end
  add(t, P)
  return t
end


function parse_fix(R)
  local t = split(R, ',')
  local S = {}
  for a = 1, #t, 1 do
    local T = split(t[a], ' ')
    local U = T[1]
    local V = T[2]
    local W = T[3]
    local X = T[4]
    S[U] = {xfix = V, yfix = W, xfixr = X}
  end
  return S
end


function parse_anims(Y)
  local t = split(Y, '|')
  local S = {}
  for a = 1, #t do
    local T = split(t[a], ':')
    local Z = T[1]
    local _ = split(T[2], ',')
    S[Z] = {}
    for M = 1, #_ do
      local J = split(_[M], ' ')
      local a0 = {}
      a0['frame'] = J[1]
      a0['duration'] = tonum(J[2])
      a0['damage'] = tonum(J[3])
      add(S[Z], a0)
    end
  end
  return S
end


function parse_supers(a1)
  local t = split(a1, ',')
  local E = {}
  for a = 1, #t, 1 do
    local T = split(t[a], '.')
    local K = split(T[1])
    local a2 = {num = K[1], seq = {}, projectile = false}
    for a3 = 2, #K do
      add(a2.seq, K[a3])
    end
    a2.sfx = tonum(T[2])
    a2.vx = tonum(T[3])
    a2.vy = tonum(T[4])
    local a4 = split(T[5])
    if a4[1] == '1' then
      a2.projectile = {speed = tonum(a4[2]), damage = tonum(a4[3])}
    end
    add(E, a2)
  end
  return E
end


function get_area(t, q, p, a5, a6)
  local J = {}
  for a7 = p + 1, p + a6, 1 do
    local L = {}
    for a8 = q + 1, q + a5, 1 do
      add(L, t[a7][a8])
    end
    add(J, L)
  end
  return J
end


function print_outline(a9, q, p, c, aa)
  for ab = -1, 1 do
    for ac = -1, 1 do
      print(a9, q + ab, p + ac, aa)
    end
  end
  print(a9, q, p, c)
end


function rint(ad, ae)
  return flr(rnd() * (ae - ad + 1)) + ad
end


function shuffle(t)
  for a = #t, 1, -1 do
    local M = flr(rnd(a)) + 1
    t[a], t[M] = t[M], t[a]
  end
end


function hit_testing()
  local af = {p1 = {}, p1p = {}, p2 = {}, p2p = {}}
  local ag = {p1, p2}
  for a = 1, #ag do
    local ah = ag[a].anims[ag[a].anim[1]][ag[a].anim[2]]['frame']
    local ai = ag[a].frames[ah]
    local aj = ag[a].fix[ah]
    for p = 1, #ai, 1 do
      for q = 1, #ai[1], 1 do
        if ai[p][q] ~= 1 then
          local ak = 0
          local al = 0
          local am = 'p' .. tostr(a)
          if ag[a].side == 0 then
            ak = q + ag[a].x + aj['xfix']
            al = p + ag[a].y + aj['yfix']
          else
            local an = #ai[1] - q
            ak = an + ag[a].x + aj['xfixr']
            al = p + ag[a].y + aj['yfix']
          end
          if not af[am][al] then
            af[am][al] = {}
          end
          add(af[am][al], ak)
        end
      end
    end
    if ag[a].projectile then
      ah = 'p' .. tostr(ag[a].projectile.anim)
      ai = ag[a].frames[ah]
      aj = ag[a].fix[ah]
      for p = 1, #ai, 1 do
        for q = 1, #ai[1], 1 do
          if ai[p][q] ~= 1 then
            local ak = 0
            local al = 0
            local am = 'p' .. tostr(a) .. 'p'
            if ag[a].side == 0 then
              ak = q + ag[a].projectile.x + aj['xfix']
              al = p + ag[a].projectile.y + aj['yfix']
            else
              local an = #ai[1] - q
              ak = an + ag[a].projectile.x + aj['xfixr']
              al = p + ag[a].projectile.y + aj['yfix']
            end
            if not af[am][al] then
              af[am][al] = {}
            end
            add(af[am][al], ak)
          end
        end
      end
    end
  end
  local ao = 3
  for Q, a9 in pairs(af) do
    local ap = sub(Q, 2, 2)
    local aq = #Q == 3
    for ar, as in pairs(af) do
      local at = sub(ar, 2, 2)
      local au = #ar == 3
      if ap ~= at then
        if au and ag[tonum(at)].projectile and not ag[tonum(at)].projectile.hit or not au and not ag[tonum(at)].hit then
          local c = 0
          for al, ak in pairs(as) do
            if a9[al] then
              for a = 1, #ak do
                if in_array(ak[a], a9[al]) then
                  c = c + 1
                  if c >= ao then
                    ag[tonum(at)]:sethit(aq, au, f)
                    goto av
                  end
                end
              end
            end
          end
        end
      end
      ::av::
    end
  end
  if p1.hit and p1:damage() > 0 and p2.hit and p2:damage() > 0 then
    local aw = p1:atktype()
    local ax = p2:atktype()
    if aw == ax then
      return
    end
    local ay = {{aw, p1}, {ax, p2}}
    for Q, a9 in pairs(ay) do
      local aa = ay[2]
      if Q == 2 then
        aa = ay[1]
      end
      if a9[1] == 'ultra' then
        a9[2].hit = false
      end
      if (a9[1] == 'sp' or a9[1] == 'sk') and aa[1] == 'super' then
        a9[2].hit = false
      end
      if a9[1] == 'super' and (aa[1] == 'dk' or aa[1] == 'dp' or aa[1] == 'jp' or aa[1] == 'jk') then
        a9[2].hit = false
      end
      if (a9[1] == 'jk' or a9[1] == 'jp') and (aa[1] == 'dp' or aa[1] == 'dk' or aa[1] == 'sp' or aa[1] == 'sk') then
        a9[2].hit = false
      end
      if (a9[1] == 'dk' or a9[1] == 'dp') and (aa[1] == 'sp' or aa[1] == 'sk') then
        a9[2].hit = false
      end
    end
  end
end

fighter = {}
fighter.__index = fighter

function fighter:new(ap, az, U, _, aj, aA, aB, aC)
  local aD = {}
  for Q, a9 in pairs(_) do
    local aE = split(a9, '.')
    if #aE == 1 then
      local aF = sint_table(a9)[1]
      aD[Q] = gfx_chunk(0, 0, aF[1], aF[2], aF[3], aF[4], true)
    else
      aD[Q] = tms2table(a9)
    end
  end
  if aC then
    local aG = sint_table(aC)
    for aH, aI in pairs(aG) do
      local aJ = aI[1]
      local aK = aI[2]
      for Q, a9 in pairs(aD) do
        for p = 1, #aD[Q] do
          for q = 1, #aD[Q][1] do
            if aD[Q][p][q] == aJ then
              aD[Q][p][q] = aK
            end
          end
        end
      end
    end
  end
  local q = p1start
  if ap == 1 then
    q = p2start
  end
  local p = floor
  local aL = {pn = ap, ci = az, name = U, mh = 56, h = 56, ub = 0, blocking = false, bh = {}, frames = aD, fix = parse_fix(aj), anims = parse_anims(aA), supers = parse_supers(aB), anim = {'i', 1, 1}, p = false, vx = 0, vy = 0, x = q, y = p, hit = false, side = ap, rwon = 0, jm = true, ai = {}}
  setmetatable(aL, fighter)
  return aL
end


function fighter:reset()
  self.h = 56
  self.bh = {}
  self.anim = {'i', 1, 1}
  self.p = false
  self.vx = 0
  self.vy = 0
  self.x = self.pn == 0 and p1start or p2start
  self.y = floor
  self.hit = false
  self.projectile = false
end


function fighter:airun()
  self.ai.b = {}
  if self.ai.hh == nil then
    self.ai.hh = self.h
  end
  if self.ai.mood == nil then
    self.ai.mood = self:aimood()
  end
  if self.h < 0 then
    return
  end
  local aM = 0
  local aN = 0
  local b = p1.blocking
  local J = split(p1.anim[1], 1, 1)[1] == 'd'
  local S = p1:damage() > 0
  if p1.x < p2.x then
    aM = p2.x - p1.x
  else
    aM = p1.x - p2.x
  end
  aN = p1.y - p2.y
  local aO = 18
  if self.h < self.ai.hh then
    self.ai.mood = self:aimood()
    self.ai.hh = self.h
  end
  local f = 0
  local b = 1
  if self.side == 0 then
    f = 1
    b = 0
  end
  if self.ai.mood == 'of' then
    add(self.ai.b, f)
    if chance(40) then
      add(self.ai.b, 2)
    end
    if aM < aO then
      if chance(7) then
        if p1.y < self.y then
          self:aisuper('u')
        else
          if self.ub >= self.mh then
            self:aisuper('ult')
          else
            self:aisuper('f')
          end
        end
      else
        if self.y == floor then
          if chance(3) then
            add(self.ai.b, 3)
          end
          add(self.ai.b, rint(4, 5))
        end
      end
    end
  end
  if self.ai.mood == 'pa' then
    if chance(4) then
      if aM > aO then
        self:aisuper('p')
      else
        if p1.y < self.y then
          self:aisuper('u')
        else
          if self.ub >= self.mh then
            self:aisuper('ult')
          else
            self:aisuper('f')
          end
        end
      end
    end
  end
  if self.ai.mood == 'cr' then
    if chance(4) then
      add(self.ai.b, 2)
    end
    add(self.ai.b, f)
    if chance(5) then
      if chance(3) then
        if p1.y < self.y then
          self:aisuper('u')
        else
          if self.ub >= self.mh and aN < aO then
            self:aisuper('ult')
          else
            if chance(5) then
              self:aisuper('p')
            else
              self:aisuper('f')
            end
          end
        end
      else
        add(self.ai.b, rint(4, 5))
        if self.y == floor then
          if chance(2) then
            add(self.ai.b, 3)
          end
        end
      end
    end
  end
end


function fighter:aisuper(t)
  local a3 = 0
  local aP = {b = 0, f = 1, u = 2, d = 3, p = 4, k = 5}
  if self.side == 1 then
    aP.f = 0
    aP.b = 1
  end
  if t == 'p' then
    a3 = chars[self.ci].sp
  end
  if t == 'f' then
    a3 = chars[self.ci].sf
  end
  if t == 'u' then
    a3 = chars[self.ci].su
  end
  if t == 'ult' then
    a3 = 'u'
  end
  if a3 == 0 then
    return
  end
  for Q, a9 in pairs(self.supers) do
    if a9.num == tostr(a3) then
      for a, b in pairs(self.supers[Q].seq) do
        add(self.bh, {aP[b], f})
      end
      break
    end
  end
end


function fighter:aib(aQ)
  if type(self.ai) == 'table' and type(self.ai.b) == 'table' then
    return in_array(aQ, self.ai.b)
  end
  return false
end


function fighter:aimood()
  local aR = {'of', 'pa', 'cr'}
  local aS = {'80,20,0', '80,0,20', '20,80,0', '20,0,80'}
  local L = rint(1, 100)
  local aT = split(aS[self.ci], ',')
  local t = 0
  for a = 1, #aT do
    t = t + aT[a]
    if L <= t then
      return aR[a]
    end
  end
  return aR[1]
end


function fighter:update()
  if self.y > floor and self:damage() < 1 then
    self.y = floor
  end
  if vscpu and self.pn == 1 then
    self:airun()
  end
  local aU = {'dh', 'db', 'h1', 'h2', 'sb', 'fall', 'ko'}
  local aV = false
  local aW = self.anim[1] == 'd'
  if in_array(self.anim[1], aU) then
    self.hit = false
  end
  if self.hit then
    local aX = players[2]
    if self.pn == 1 then
      aX = players[1]
    end
    local aY = aX:damage()
    local aZ = 13
    local a_ = rint(10, 12)
    if self.hit[1] then
      if not aX.projectile.killframe then
        if self.blocking then
          aY = 0
          if aW then
            self:setanim('db')
          else
            self:setanim('sb')
          end
        else
          aY = aX.projectile.damage
          if aW then
            self:setanim('dh')
          else
            self:setanim('h2')
          end
        end
      end
    else
      if aY > 0 then
        local aV = sub(aX.anim[1], 1, 2) == 'su'
        local b0 = aX.anim[1] == 'ult'
        local b1 = sub(aX.anim[1], 1, 1) == 'j'
        local b2 = aX.anim[1] == 'dp'
        local b3 = sub(aX.anim[1], 1, 1) == 'd'
        if self.blocking then
          local b4 = false
          if aV or b0 then
            sfx(13)
            aY = 0
          end
          if aW and b1 then
            self:setanim('dh')
            b4 = true
          end
          if not aW and b3 then
            if b2 then
              self:setanim('h2')
            else
              self:setanim('fall')
            end
            b4 = true
          end
          if not b4 then
            if aY > 1 then
              aY = 0
            end
            if aW then
              self:setanim('db')
            else
              self:setanim('sb')
            end
          end
        else
          if aX.anim[1] == 'dk' or self.y < floor and aV then
            self:setanim('fall')
            if aX.anim[1] == 'dk' then
              a_ = 14
            end
          else
            if self.anim[1] == 'd' then
              self:setanim('dh')
            else
              if aX.anim[1] == 'dp' then
                self:setanim('h2')
              else
                self:setanim('h1')
              end
            end
          end
        end
      end
    end
    local b5 = ceil(aY / 7 + 1)
    if self.side == 0 then
      b5 = 0 - b5
    end
    self.vx = self.vx + b5
    if aY > 0 then
      if vscpu then
        if aX.pn == 1 then
          aY = aY + (curopp - 1) * 2
        end
      end
      self.h = self.h - aY
      self.ub = self.ub + aY * 2
      if self.pn == 1 then
        score = score + aY
        if aV then
          score = score + aY * 4
        end
        if self.anim[1] == 'ult' then
          score = score + aY * 9
        end
      end
      sfx(a_)
    else
      if aX:damage() > 0 then
        sfx(aZ)
      end
    end
    if self.h < 0 then
      self:setanim('ko')
      self:kosfx()
      if self.pn == 1 then
        score = score + rtd * 2
      end
    end
    self.hit = false
  end
  local ah = self.anims[self.anim[1]][self.anim[2]]['frame']
  self.anim[3] = self.anim[3] + 1
  if self.anim[3] > self.anims[self.anim[1]][self.anim[2]]['duration'] then
    if self.anims[self.anim[1]][self.anim[2] + 1] == nil then
      if self.y < floor then
        self.anim = {'j', 1, 1}
      else
        self.anim = {'i', 1, 1}
      end
    else
      local b6 = true
      if ah == 'f2' and self.y < floor then
        b6 = false
      end
      if b6 then
        self.anim[2] = self.anim[2] + 1
        self.anim[3] = 1
      end
    end
  end
  local b7 = false
  for a9 in all(b) do
    if not b7 then
      if btnp(a9, self.pn) then
        if #self.bh > 0 then
          if self.bh[#self.bh][1] ~= a9 then
            add(self.bh, {a9, f})
          end
        else
          add(self.bh, {a9, f})
        end
        b7 = true
      end
    end
  end
  local b8 = 0.0020
  local b9 = {}
  for a = 1, #self.bh do
    if f - self.bh[a][2] <= b8 then
      add(b9, self.bh[a])
    end
  end
  self.bh = b9
  local ba = {'1', '2', '3', '4'}
  local bb = split(self.anim[1])
  for a = 1, #ba do
    if bb[1] == 's' and bb[2] == 'u' and bb[3] == ba[a] then
      self.bh = {}
    end
  end
  if self.anim[1] == 'ult' then
    self.bh = {}
  end
  local aP = {b = 0, f = 1, u = 2, d = 3, p = 4, k = 5}
  if self.side == 1 then
    aP.f = 0
    aP.b = 1
  end
  if #self.bh > 2 then
    for a = 1, #self.supers do
      local Q = self.supers[a].num
      local a9 = self.supers[a]
      if Q == 'u' then
        if self.ub < self.mh then
          goto bc
        end
      end
      if a9.projectile and self.projectile then
        self.bh = {}
        goto bc
      end
      local bd = #a9.seq
      if #self.bh < bd then
        goto bc
      end
      for a = 1, bd do
        local be = self.bh[#self.bh - (bd - a)][1]
        local bf = a9.seq[a]
        if aP[bf] ~= be then
          goto bc
        end
      end
      sfx(a9.sfx)
      self.projectile = a9.projectile
      if self.projectile then
        self.projectile.x = self.x
        self.projectile.y = self.y
        self.projectile.anim = 1
        self.projectile.f = f
        self.projectile.animf = 0
        self.projectile.hit = false
        self.projectile.side = self.side
        self.projectile.killframe = false
      end
      if Q == 'u' then
        ultanim = {self.pn, f}
        self.ub = 0
      else
        self:setanim('su' .. Q, true)
        self.ub = self.ub + 5
      end
      local bg = a9.vx
      if self.side == 1 then
        bg = 0 - bg
      end
      self.vx = bg
      self.vy = a9.vy
      self.bh = {}
      ::bc::
    end
  end
  local bh = 2
  local bi = -6
  self.blocking = false
  local bj = {'cHI', 'lUA'}
  if in_array(self.name, bj) then
    bh = 3
    bi = -7
  end
  local bk = self:damage()
  if bk == 0 then
    if self.y == floor then
      local bl = {'f', 'b'}
      local bm = 0
      if self.side == 1 then
        bl = {'b', 'f'}
        bm = 1
      end
      if btn(3, self.pn) or self:aib(3) then
        self:setanim('d', false)
        if btn(bm, self.pn) or self:aib(bm) then
          self.blocking = 2
        end
      end
      if self.anim[1] ~= 'd' then
        if btn(bm, self.pn) or self:aib(bm) then
          self.blocking = 1
        end
        if btn(0, self.pn) or self:aib(0) then
          self.x = self.x - bh
          self:setanim(bl[2], false)
        end
        if btn(1, self.pn) or self:aib(1) then
          self.x = self.x + bh
          self:setanim(bl[1], false)
        end
        if btn(2, self.pn) or self:aib(2) then
          self.jm = true
          self.vy = bi
          self:setanim('j', false)
        end
        if btnp(4, self.pn) or self:aib(4) then
          self:setanim('sp', true)
        elseif btnp(5, self.pn) or self:aib(5) then
          self:setanim('sk', true)
        end
      else
        if btnp(4, self.pn) or self:aib(4) then
          self:setanim('dp', true)
        elseif btnp(5, self.pn) or self:aib(5) then
          self:setanim('dk', true)
        end
      end
    else
      if btn(0, self.pn) or self:aib(0) then
        if self:canjm() then
          self.x = self.x - bh
        end
      end
      if btn(1, self.pn) or self:aib(1) then
        if self:canjm() then
          self.x = self.x + bh
        end
      end
      if btnp(4, self.pn) or self:aib(4) then
        self:setanim('jp', true)
      elseif btnp(5, self.pn) or self:aib(5) then
        self:setanim('jk', true)
      end
    end
  else
    if self.anim[1] == 'jk' or self.anim[1] == 'jp' then
      if btn(0, self.pn) or self:aib(0) then
        if self:canjm() then
          self.x = self.x - bh
        end
      end
      if btn(1, self.pn) or self:aib(1) then
        if self:canjm() then
          self.x = self.x + bh
        end
      end
    end
  end
  self.y = flr(self.y + self.vy)
  if self.y < floor then
    self.vy = self.vy + 0.5
  end
  local bn = floor
  if bk > 0 then
    bn = floor + 8
  end
  if self.vy ~= 0 and self.y >= bn then
    self.y = floor
    self.vy = 0
    if ah ~= 'f2' then
      self:setanim('i', true)
    end
  end
  if self.side == 0 then
    self.x = flr(self.x + self.vx)
  else
    self.x = ceil(self.x + self.vx)
  end
  self.vx = self.vx * 0.8
  if abs(self.vx) < 1 then
    self.vx = 0
  end
  if self.side == 0 and self.x < -6 then
    self.x = -6
  end
  if self.side == 1 and self.x > 121 then
    self.x = 121
  end
end


function fighter:kosfx()
  local bo = {kYU = 15, sOL = 16, cHI = 17, lUA = 17}
  sfx(bo[chars[self.ci].name])
end


function fighter:damage()
  return self.anims[self.anim[1]][self.anim[2]]['damage']
end


function fighter:atktype()
  if self:damage() < 1 then
    return ''
  end
  local aV = sub(self.anim[1], 1, 2) == 'su'
  if aV then
    return 'super'
  end
  local b0 = self.anim[1] == 'ult'
  if b0 then
    return 'ultra'
  end
  return self.anim[1]
end


function fighter:draw()
  local ah = self.anims[self.anim[1]][self.anim[2]]['frame']
  local ai = self.frames[ah]
  local aj = self.fix[ah]
  self:draw_shadow(ai, aj, false)
  for p = 1, #ai, 1 do
    for q = 1, #ai[1], 1 do
      if ai[p][q] ~= 1 then
        if self.side == 0 then
          pset(q + self.x + aj['xfix'], p + self.y + aj['yfix'], ai[p][q])
        else
          local an = #ai[1] - q
          pset(an + self.x + aj['xfixr'], p + self.y + aj['yfix'], ai[p][q])
        end
      end
    end
  end
  if pause then
    return
  end
  self:handleprojectile()
end


function fighter:setanim(bp, bq)
  if self.anim[1] ~= bp or bq then
    self.anim = {bp, 1, 1}
  end
end


function fighter:handleprojectile()
  if not self.projectile then
    return
  end
  local br = 0.0004
  if f - self.projectile.f < br then
    return
  end
  local ah = 'p' .. tostr(self.projectile.anim)
  if self.projectile.hit then
    ah = 'ph'
    if not self.projectile.killframe then
      self.projectile.killframe = 0.0002 + f
    end
  end
  local ai = self.frames[ah]
  local aj = self.fix[ah]
  self:draw_shadow(ai, aj, true)
  for p = 1, #ai, 1 do
    for q = 1, #ai[1], 1 do
      if ai[p][q] ~= 1 then
        if self.projectile.side == 0 then
          pset(q + self.projectile.x + aj['xfix'], p + self.projectile.y + aj['yfix'], ai[p][q])
        else
          local an = #ai[1] - q
          pset(an + self.projectile.x + aj['xfixr'], p + self.projectile.y + aj['yfix'], ai[p][q])
        end
      end
    end
  end
  local bs = self.projectile.speed
  if self.projectile.side == 1 then
    bs = 0 - bs
  end
  self.projectile.x = self.projectile.x + bs
  self.projectile.animf = self.projectile.animf + 1
  if self.projectile.animf > 2 then
    self.projectile.animf = 0
    self.projectile.anim = self.projectile.anim + 1
    if self.projectile.anim > 3 then
      self.projectile.anim = 1
    end
  end
  local bt = false
  if self.projectile.x > 127 or self.projectile.x < -8 then
    bt = true
  end
  if self.projectile.killframe and f >= self.projectile.killframe then
    bt = true
  end
  if bt then
    self.projectile = false
  end
end


function fighter:sethit(bu, bv, f)
  if bv then
    if self.projectile then
      self.projectile.hit = {bu, f}
    end
  else
    self.hit = {bu, f}
  end
end


function fighter:canjm()
  if not vscpu then
    return true
  end
  if vscpu and self.pn == 0 then
    return true
  end
  local aM = 0
  if p1.x < p2.x then
    aM = p2.x - p1.x
  else
    aM = p1.x - p2.x
  end
  if aM < 8 then
    self.jm = false
  end
  return self.jm
end


function fighter:draw_shadow(ai, aj, aq)
  local aC = {}
  local bw = self.x
  local bx = self.y
  local by = self.side
  if aq then
    bw = self.projectile.x
    bx = self.projectile.y
    by = self.projectile.side
  end
  for p = 1, #ai, 1 do
    for q = 1, #ai[1], 1 do
      if ai[p][q] ~= 1 then
        local ab = q + bw + aj['xfix']
        local ac = p + bx + aj['yfix']
        if by == 1 then
          local an = #ai[1] - q
          ab = an + bw + aj['xfixr']
        end
        if aC[ab] == nil then
          aC[ab] = 0
        end
        aC[ab] = aC[ab] + 1
      end
    end
  end
  for Q, a9 in pairs(aC) do
    if a9 >= 10 then
      line(Q - 1, floor + 20, Q - 1, floor + 22, 0)
      line(Q + 1, floor + 20, Q + 1, floor + 22, 0)
    else
      pset(Q - 1, floor + 21, 0)
      pset(Q + 1, floor + 21, 0)
    end
  end
end


function draw_main()
  cls(1)
  local bz = screen_conf['main']
  if bz.logloc <= 0 then
    bz.logloc = bz.logloc + 6
  end
  if bz.optloc >= 0 then
    bz.optloc = bz.optloc - 6
  end
  gfx_chunk(19, bz.logloc + 10, 0, 0, 90, 49)
  print_outline('1p VS cpu', 46, 90 + bz.optloc, 7, 0)
  print_outline('1p VS 2p', 46, 100 + bz.optloc, 7, 0)
  local bA = tostr(high_score)
  if high_score > 0 then
    bA = bA .. '00'
  end
  local bB = 'high score ' .. bA
  print(bB, ctxtx(bB), 120 + bz.optloc, 12)
  if bz.logloc >= 0 and bz.optloc <= 0 then
    if bz.sel ~= 2 then
      bz.sel = 1
    end
    if bz.sel == 1 then
      vscpu = true
      spr(128, 37, 83)
    end
    if bz.sel == 2 then
      vscpu = false
      spr(128, 37, 93)
    end
  end
  if btnp(2) then
    sfx(4)
    bz.sel = 1
  end
  if btnp(3) then
    sfx(4)
    bz.sel = 2
  end
  if btnp(4) or btnp(5) then
    sfx(5)
    screen = 'charselect'
  end
end


function draw_charselect()
  cls(1)
  local bz = screen_conf['charselect']
  print_outline('sELECT yOUR fIGHTER', 25, 6, 8, 10)
  local bC = {}
  local bD = {21, 21, 21, 21, 52}
  for a = 1, #chars do
    add(bC, {bD[3], bD[4]})
    bD[3] = bD[3] + bD[5]
    if bD[3] > bD[5] * 2 then
      bD[3] = bD[1]
      bD[4] = bD[4] + bD[5]
    end
  end
  if not bz.psel then
    bz.psel = {1, 2, false, false}
  end
  for a = 1, #bC do
    if bz.psel[1] == a then
      draw_avt(1, bz.psel[1], bC[a][1], bC[a][2], true)
    end
    if not vscpu then
      if bz.psel[2] == a then
        draw_avt(2, bz.psel[2], bC[a][1], bC[a][2], true)
      end
    end
    draw_avt(1, a, bC[a][1], bC[a][2], false)
  end
  for a = 0, 1 do
    if a == 1 and vscpu then
      break
    end
    local aa = a == 0 and 1 or 0
    local bE = false
    local bF = bz.psel[a + 1]
    if btnp(0, a) and bF % 2 == 0 then
      sfx(4)
      if bF == 2 then
        bE = 1
      else
        bE = 3
      end
    end
    if btnp(1, a) and bF % 2 == 1 then
      sfx(4)
      if bF == 1 then
        bE = 2
      else
        bE = 4
      end
    end
    if btnp(2, a) and bF > 2 then
      sfx(4)
      if bF == 3 then
        bE = 1
      else
        bE = 2
      end
    end
    if btnp(3, a) and bF < 3 then
      sfx(4)
      if bF == 1 then
        bE = 3
      else
        bE = 4
      end
    end
    local bG = true
    if not vscpu and bz.psel[aa + 1] == bE then
      bG = false
    end
    if bG then
      if bE then
        bz.psel[a + 1] = bE
      end
    end
    if vscpu then
      if btnp(4, a) or btnp(5, a) then
        sfx(5)
        screen = 'vs'
      end
    else
      if btnp(4, a) or btnp(5, a) then
        sfx(5)
        bz.psel[a + 3] = true
        if a == 0 then
          if bz.psel[4] then
            screen = 'vs'
          end
        end
        if a == 1 then
          if bz.psel[3] then
            screen = 'vs'
          end
        end
      end
    end
  end
end


function draw_vs()
  cls(1)
  local bz = screen_conf['vs']
  local bH = 10 - #bz.bg
  for a = 1, bH do
    add(bz.bg, {rint(0, 127), rint(127, 256), rint(1, 2), rint(40, 120)})
  end
  for a = 1, #bz.bg do
    rectfill(bz.bg[a][1], bz.bg[a][2], bz.bg[a][1] + bz.bg[a][3], bz.bg[a][2] + bz.bg[a][4], 0)
    bz.bg[a][2] = bz.bg[a][2] - 25
    if bz.bg[a][2] + bz.bg[a][4] < 0 then
      bz.bg[a] = false
    end
  end
  local bI = {}
  for a = 1, #bz.bg do
    if bz.bg[a] then
      add(bI, bz.bg[a])
    end
  end
  bz.bg = bI
  if not bz.locrt then
    bz.locrt = {bz.vsloc[1], bz.vsloc[2]}
  end
  bz.locrt[1] = bz.locrt[1] + 10
  bz.locrt[2] = bz.locrt[2] - 10
  if bz.locrt[1] > 12 then
    bz.locrt[1] = 12
  end
  if bz.locrt[2] < 82 then
    bz.locrt[2] = 82
  end
  psel = screen_conf['charselect']['psel']
  if vscpu then
    psel[2] = ford[psel[1]][curopp]
  end
  draw_avt(1, psel[1], bz.locrt[1], 45, true)
  draw_avt(2, psel[2], bz.locrt[2], 45, true)
  print_outline('vs', 60, 60, 8, 10)
  if btnp(4) or btnp(5) then
    sfx(5)
    if bgm then
      music(2)
    end
    local bJ = chars[psel[1]]
    local bK = chars[psel[2]]
    p1 = fighter:new(0, psel[1], bJ.name, bJ.frames, bJ.fix, bJ.anims, bJ.supers, bJ.shadow)
    p2 = fighter:new(1, psel[2], bK.name, bK.frames, bK.fix, bK.anims, bK.supers, bK.shadow)
    players = {p1, p2}
    screen = 'fight'
    new_round(true)
  end
end


function draw_gameover()
  cls(1)
  local bL = 'you lose'
  print_outline(bL, ctxtx(bL), 20, 8, 10)
  if score > 0 then
    local bM = 'score ' .. score .. '00'
    print(bM, ctxtx(bM), 40, 12)
    if score > high_score then
      dset(0, score)
      local bN = 'new high score!'
      print(bN, ctxtx(bN), 50, 11)
    end
  end
  draw_winmsg(2)
  if btnp(4) or btnp(5) then
    run()
  end
end


function draw_wingame()
  cls(1)
  local bL = 'you won!'
  print_outline(bL, ctxtx(bL), 20, 8, 10)
  local bM = 'score ' .. score .. '00'
  print(bM, ctxtx(bM), 40, 12)
  if score > high_score then
    dset(0, score)
    local bN = 'new high score!'
    print(bN, ctxtx(bN), 50, 11)
  end
  draw_winmsg(1)
  if btnp(4) or btnp(5) then
    run()
  end
end


function draw_winmsg(ap)
  for Q, a9 in pairs(chars) do
    if players[ap].name == a9.name then
      spr(a9.avt, 48, 60, 4, 4)
      print(a9.winm[1], ctxtx(a9.winm[1]), 98, 7)
      print(a9.winm[2], ctxtx(a9.winm[2]), 106, 7)
    end
  end
end


function draw_avt(ap, bO, q, p, bP)
  c = 12
  if ap == 2 then
    c = 8
  end
  if bP then
    rectfill(q - 2, p - 2, q + 33, p + 33, c)
    rectfill(q, p, q + 31, p + 31, 1)
    print_outline(chars[bO].name, q + 11, p + 38, c, 0)
  end
  spr(chars[bO].avt, q, p, 4, 4)
end


function gfx_chunk(q, p, ab, ac, bQ, bR, rt)
  local t = {}
  for aN = 0, bR - 1 do
    local L = {}
    for aM = 0, bQ - 1 do
      local c = sget(ab + aM, ac + aN)
      add(L, c)
      if not rt then
        if c ~= 1 then
          pset(q + aM, p + aN, c)
        end
      end
    end
    add(t, L)
  end
  if rt then
    return t
  end
end


function sint_table(E)
  local J = split(E, '|')
  local t = {}
  for Q, a9 in pairs(J) do
    local S = split(a9, ',')
    local T = {}
    for ar, as in pairs(S) do
      add(T, tonum(as))
    end
    add(t, T)
  end
  return t
end


function advance()
  p1.rwon = 0
  curopp = curopp + 1
  if curopp > 3 then
    score = score * 2
    music(-1)
    sfx(42)
    screen = 'wingame'
  else
    psel = screen_conf['charselect']['psel']
    psel[2] = chars[ford[p1.pn + 1]]
    screen_conf['vs']['locrt'] = false
    screen = 'vs'
  end
end


function new_round(bS)
  rtd = 60
  draw = false
  local bT = bS and 1 or roundn[1] + 1
  roundn = {bT, f, t(), false, false}
  p1:reset()
  p2:reset()
  pause = false
  slowmo = false
  if bS then
    shuffle(clouds)
    numclouds = rint(1, 5)
  end
  if vscpu and p2.rwon == 2 then
    music(-1)
    sfx(41)
    screen = 'gameover'
  end
  if vscpu and p1.rwon == 2 then
    advance()
  end
  if not vscpu and (p1.rwon == 2 or p2.rwon == 2) then
    screen = 'charselect'
  end
end


function chance(bU)
  if rint(1, bU) == 1 then
    return true
  end
  return false
end


function ctxtx(C)
  return flr(64 - #C * 4 / 2)
end


__gfx__
111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111115fef11111d76711111111111111111
111111111111111111111111111111111111111111115555444444511111111111111111111111111111111111111111556d45111776667d1111111111111111
111111111111111111111111111111115549aaaaaaaaaaa9444449011111111111111111111111111111111111115f5f6d77550d6dd5d6611111111111111111
11111111111111111111111111111111aaaa99444aa950000000001111111111111111111111111111111111111afe4767664f0d6d766665dd11111111111111
111111111111111151111111111111149445000004a500111111111111111111111111111111111111111111111aa5dfffedd505dd66666d666fffd111111111
111111111115aaaaaa9aa901111111111111111119a0111111115aaaa4511111111111111111111111111111111aa9deeeffff502fddd6dd6664fe5111111111
11111111159aaaaaaa940011111111111111111119a01111111119aaaaaa5111111111111111111111111111111aaa1115544400541111111111111111111111
111111119aaaaaaaa400011111111111111111511aa01111111111a959aaa1111111111111111111111111111111111111111111111111111155111111111111
1111111aaaaaaaa500111111149aa1114a11a9911aa11155441111a90059a1111111111111111111111111111111aaaaaa11111111111115fffe511111111111
11119aaaa9a4500111511119a9aaa111a9019a4059a11999940111a411159511111111111115555111111111111111aa9ad1111111111d6fe514511111111111
1111a9999a9001111199114a999500119901994159911990001111951119901111111544999999999944445551111d9e966fe511111d67641111111111111111
111499999a011111159a1199900011119401994149911991111514941499901111111aaaaaaaaaaaaaaaaaa94511dd4ead66ef411d67766d1111111111111111
11599959990111511999019951549911999999014991594544119999999401111115aaaaaaaaa9aaaa999a01111d67650456d4f667766d111111111111111111
1149400994154911199411990199990199999901499149999411999999920111155500005aa4000aa50000111116fe4e544d6666666d11111111111111111111
1149005994199941199411990149920194009901499149999011499009991111111000111aa0011a9011111111154feff6765666664511111111111111111111
1142015999999991599211990114901590119901994149400011494014994111111111114aa0115a40111111111154ee666d56d661dd11111111111111111111
111112999994200149901199924990128011940189418801111288211188811111111111aaa1119a01111111111111555dd057d6111111111111111111111111
111114999940011149401188898880144011840188418824441488011148821111111111aaa115a9011111111111111111105d6d111111111111111111111111
111114884001111148401128888881144012841188418888841888011128881111111111aa9115a5011111111111111111105666111111111111111111111111
111114884011111188401112444881144012841128418888841888011118884111111111aa4114a011111111111111111111d666111111111111111111111111
111111882111111188411111111881124111421111010000118448111112844211111115aa011aa0111111111111111111115676111111111111111111111111
111112882111111182411111111001110111001111011111110000111111400011111114a4014aa1111111111111111111115667511111111111111111111111
111114880111111100411111111111110111111111111111111111111111011111111119a5119aa1111111111111111111115dd6511111111111111111111111
11111108011111111111111111111111111111111111111111111111111111111111115a9015aa41111111111111111111115666111111111111111111111111
11111110011111111111111111111111111111111111111111111111111111111111114a4015aa01111111111111111111115666111111111111111111111111
1111111101111111111111111111111111111111111111111111111111111111111111995114a90111111111111111111111114e111111111111111111111111
111111111111111554a511111111111111111111111111111111111111111111111111990119a4011111111111111111111115ff111111111111111111111111
111111111119aaaaa955001111111111111111111111111111111111111111111111149901199011111111111111111111114d54111111111111111111111111
1111111115aaaaa500001111111111111555444999aaaaaaaaaaaaa994551111111114991119901111111111111111111111111aaa1111111111111111111111
111111119aaaa500111111111115599aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa4511111199911194011111111111111111111111a99aaa111111111111111111111
1111114aaaa0011111115aaaaaaaaaaa9994500000000000050004a90000059aa11129941149011111111111111111111111adfe9f1111111111111111111111
111115aaaa01111111114aaaaaaa944550000111554911aaaa1119a401111109a111499211490111111111111111111111466667efd555555111111111111111
111119aaaa0111111115aaa9aa400999aa951111aaaa11a94401199011111119a11148901144011111111111111111111166d667fffffffff55f411111111111
11111aaaaa4111111119a405aa001aaa99aa1115a45001a00011599011111499411188801284011111111111111111111e66d667ee4444455111511111111111
111114aaaaaaaaa4111111199511119a0119911494411499a911990111499000111188201480111111111111111111111fddd6666dd111111111111111111111
1111114aaaaa999a911111199011149911599014999014945011990111550011111188011880111111111111111111111edd6667661111111111111111111111
111111105449a999a91111599011199954990019940019900015990111101111111188012880111111111111111111111115555d6d1111111111111111111111
11111111111114999911119991111994449911190111199244199411111111111114820148811111111111111111111111166676111111111111111111111111
111111111111159999111199911119400099115944412999941994111111111111288211888111111111111111111111116d66d7511111111111111111111111
11111111111119999911119941111940114911499991244420542011111111111288842288822221111111111111111111d676d6561111111111111111111111
111111111111499994111199011149211129412442011000001000111111148888888888888888884011111111111111116676dd676111111111111111111111
1111111111499999001112940111100111100011111111111111111111128888888888888888888840111111111111111d6665dd666611111111111111111111
1111111149988890011114400111111111111111111111111111111112444222200000000000000000111111111111115d67d115ddd711111111111111111111
11111119988888401111110011111111111111111111111111111111100000000000011111111111111111111111111666661111666611111111111111111111
1111488888884001111111111111111111111111111111111111111111111111111111111111111111111111111111566dd111116d6611111111111111111111
1888888884201111111111111111111111111111111111111111111111111111111111111111111111111111111111e4dd111111d66611111111111111111111
1488888420011111111111111111111111111111111111111111111111111111111111111111111111111111111114fd11111111441111111111111111111111
11488840001111111111111111111111111111111111111111111111111111111111111111111111111111111111114f11111111ffd111111111111111111111
11110011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111551111111555511111111111111111111
111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111aaa11111111111111111111111111111111
111111111a111111111111111111111111aa1111111111aa11111111a1111111111111111111a1111111111111566ddaaa111111111111111111111111111111
11111111a9aa11111111111111111111aaaaaa111111aaaaaa1119aaaaaa111d1111111111aa9aa1111111111efd7d559a111111111111111111111111111111
1111115dd6661111111111111111154477fee111111117fee111115d49aa114d111111116666aeedd555151114f56de4f4411111111111111111111111111111
1111166d667ff11111111111111114ffd65fdd411114475fdd41111fde49df105111111e66679fffffff55f4e4fd55f447ef1111111111111111111111111111
1111e6dd66deed1111111111111115efd5506441115ffd55fff411deddff644fd111114d6666e44555111111eef045fee64fe511111111111111111111111111
111ffdd66664ef111111111111115dfff45e6501115efff45f5115effdd4654f1111111d66666611111111114ee4677e5115eff1111111111111111111111111
11fed5d6dd6d54f1111111111111164ee4644e11115dfee46d4111d4ff76dd111111111d666661111111111100056665d1112454111111111111111111111111
11fe655d7776d4e41111111111111555d5dd7677111645d57d6771ddfef452de1dd11110567565dd111111111dd666666d6d1111ef1111111111111111111111
15515ddd6666677777761111111116775dd7666716755ddd7666711d5fe40044d667116d7756d6d77111111115d6dd6dd667f6d1151111451111111111111111
4ef1166d666666666777fd111151667760d6d6651667760d6d665111567d55d6766d11dd6775dd666111111111666dddd66ffe77777d11fe1111111111111111
1111111d544555ddd6664effffef466666dd6661f466666dd6661111556677ddd665e21d6776d66611111111117677774ffed66666d4fff11111111111111111
1111111115e4111111111115f11f4dddd7644111f4dddd7644111111ef5d6675d661e4ddd677e45511111111116666661111155ddd5111f11111111111111111
111111111dd1111111111111111f4566666ee511f4566666ee511111f566d66de111f4d66666f5111111111111155dd511111111111111111111111111111111
11111111111111111111111111111111111155111111111115511111dd15d665fe51551115515441111111111111111111111111111111111111111111111111
00111111111111111d1111111111111111d11111111c111c6676d1111c1151117777777fff7760054dd501001111115277777feef666666666f7777765d6ff77
0701111111111111611ddcc66c11116dccc6666d116ddc6766676c11116d1611aa99999aaff77d6f766f500000000001777fe88888e41111015556f65555dd6f
077011111111111d7dd66cc77761dcd6cccc6c76cd6cc6c66677761111d6dd1144444444444ff777777775055000001177e888e44448252555555155225d6666
077701111111111cc676cc7777cd1cc66cc777676d7cc666667776111d677d11eeeff951dffffff77fff77677666d00177e82484224885222551555525df7777
0770111111111111d666cc7777c1dcc66cc676676161dc676c666111136677c1ffff400d7fffff777777f7777777775077e8224e44888222222215555555dd6f
070111111111111111d66ccc66c11cccc6c6ccc61111111d666c11d666c77776ff40000f7ffff77ffff777faf777777677f882244888822225522155555555dd
00111111111111111cc1dc666d111166d66666c111111111111111111c66776ca40010f7faf777ffffffff4ffaf77f7777e488208e4845222255551552d55577
11111111111111111111ee111111eee111111e111111111111111111116677d140165d7fff777777ffffa4249faf77f7778428428448222225551555555225d7
aaaa7777111eee1e11eeefe11eeee7ee11e111e11111111111111111dd6c77c105fd0fff77777777777f4448449af77f7d282222228255554444d4552255525d
1aaaa7711eeef7e11eee7fee111eeffe1111e171111111111111111d1ddcc611e60004af777f77f777f444f48444ff7761d882244885205ffffffff515d5155d
1aaa777111eee7e1111eee111111ee1111ee7ee11111111111111111d11d1d114fff64f777fa7ff77744effe48444ff755dd2522225515f7fffffffd15255ddd
11aaa711111eee111111111111111111e11e17e11111111111111111111dd111024ede7777af7fff7e4effff44444eef55dd522551551efffffffffe1122566d
111a71111111111111111111111111111111e7111111111111111111111111110000077f7ff7ffaff4f7fffff444444fd5dd222525115fffffefffff5155567d
111a711111111111111111111111111111117ee7111111111111111111111111000577af7f77ffffff777fffff4244e5d2dd22224f515ff7fff44fff41555d76
11aaa7111111111111111111111111111111e1e111111111111111111111111100467fe77f7feaf424f77ffff4244444d26d22254a415ffedeff44fff5555d7f
11111111111111111111111111111111111e111111111666661111111111111100157ff7777eff442004fffe20542e44d26d2225ff415ff50004ffff4455d676
111111111111111111111111111111111e1111111111677777711111111111111006fef777ff444ff4449ff44fd00050d2d6622d45f54ffe55d5efff555ddff6
11111111111111111111111111111111111111111116777677771111111111110057fef77fef44fffffffff99f600000dddd755244fddffffffffff5111667ff
111111111111111111111111111111111111111111166766777711111111111100674fff79ff4f7fffff7ffe9f600000dd6d7d114fffffffffffff95451df777
1111111111111111111111111111111111111111111116777766776111111111167f44e7fffff7fffffffffff7600000ddddfd51566fffffffffffe9405d7777
1111111111111111111111111111111111111111111166777767777711111111564f44f7efff7fffffffff7ff7741000dddd7fd5d66fffffffffffff40567777
11111111111111111111111111111611111111111166666777677777111111110057ffffee67fffffffffffff77f6d005dd67765fef7ffffffffffffd1df7777
11111111111111111111111111166771111111111166776777777777111111110077feef4407fffffffff44ff760010052d677f6ffffffffffffffffd2d77777
11111111111167111111111111167771776111116677777777777776671111110177e4edd40d7fffffffffeffff500002dd676dfffed7fffffffff7f6df77777
111111111167777111111111116677777761111166777777777777777777111110df9fe467e477fffffffffff64fd0002de6f1dffff4d7fffff447676d777777
11111116716667771111166166666777667711111667777767777767777776110057ffe2d77e477ffffffe9f77447f502de6655f7ffe5d7fffff76576d777777
1111116677667766771666777667777667777116666677766666666677777771d5f7fa42f77f4267ffff999f776fff002de6d5dddfff415ffff7f5576d777777
1111166666666666661666666666666666666111111111111111111111111111f7ffa444f7f7f4057fffffff777777652dd6d2dddd4445156ffff5d7d5777777
1111111111111111111111111111111111111111111111111111111111111111f7ff99f4f7f7f994effffff77777777722dd4444dd554555ff6ff5f7d5777777
11111111111116677611111111111111111116111677711111111111111111117444f742f77ffe94677777777777777752dd244442dd0515f777d5d765f77777
11111111111667777771111111111111111166716777771171111111111111112000d76d677eeef477777777777777775dddd244dd66d5556f65122dd5f77777
111166711166676777711671111111111111667766777716611111111111111112156776777feffe777777777777777752ddddd4ddeddd55511111222d67777f
11166777116666777776166771667111111667777667766677711111677111116676766777776544677500455500000500055d65000001555515510155cc6d50
1116777776666677766667777667771111667777666766777677776666777711676677777776255005d00444444444440d77ccc6d0566ccccc676766ccc6d510
666666666666666666666666666666666166666666666666666666666666661176777776d76000000000244884428844dddd6c77766ccccc66c777ccccd00000
111111dddd111111111111111111111111111111111111111111111111111111777d111001002220002222226e44222200001d6776ccccc6c67776ccc6dd5550
11111dddddd111111111115555511111111111111111111111111111111111117d0000000002000000244420577e44240d6cc776cc766cc77767776c676cc6d6
1111ddddddddd1111111155555555551111111111111111111111111111111115000000444000545000222205777744576cc67776cc676777cc76c7c7777cc10
11ddddddddddddd11111555555555555111111111111111111111111111111110020024444254455450002440576774405c67776c67777777c66777c6776cc65
dddddddddddddddd111155555555555551111111111111111111111111111111020044448e4455450000000420d6567e06c76cccc77777776cc77c7cc766ccc6
ddddddddddddddddd6655555555555555511dddd111111111111111111111111200444488444400000000000402745e7dcc6c676c7766667677667776cccccc7
ddddddddddddddddd555555555555555555dddddd1166611111dddddd11666660044488844488200000040000447775476cc677cc777777777677cc6cccc6c66
dddddddddddddddd55555555555555555555dddddd6666666ddddddddd66666654448e8442244400020042000245222476c6776c67777777776c6c6cc66ccc06
ddddddddddddddd555555555555555555555dddddddd666dddddddddddd6ddd64444e8442222482045200400002444f776d666cc67777777776ccccc677ccc55
dddddddddddddd555555555555555555555555dddddddddddddd555555ddddd64d4ee44222220242542004002007777770dc7cc6777777777776ccccc6776c60
dd555dddddddd55555555555555555555555555ddddddddddd5555555555dddde28ee422222000441442002004006777d06c6c677776d77777767c7dc7766c61
5555555ddddd55555555555555555555555555555ddddd5555555555555555dd44444e420420024e4542205002401477d066c6d777767776677676c7c767cccd
55555555dd55555555555555555555555555555555555555555555555555555d444eee7f22224f7ee44420000120d677d05766dd77776500577777c7c776c7c6
555555555555555555555555555555555555555555555555555555555555555576777524422884422844420002205777d1177ddd7777d6556777775fc67d67cc
555555555555555555555555555555555555555555555555555555555555555577777504400244440244422000220d7705067c515777777777777756cc616ccc
555555555555555555555555555555555555555555555555555555555555555577777504400024422004224000240177000176ddd777777777777776cc6067cc
111111111dddd111111111111111111111111111111111111111111111111111777775040020222222002022024440570000d6cff777777777777776cc65d7cc
11111111ddddddd11111116611111111111111111111111111111111111111117776d004000222222420002202844456000056c677777777777777776c00d7cc
111111dddddddddd11111666661111111111111111111111111666661111111d77554004222222222222022222240d770000176677777777777777776d00d7cc
1111dddddddddddddd16666666661111111111111111111666666666661111dd776771022442222222200f42242000770000067d77777777777777777d00d7cc
ddddddddddddddddddd66666666666111111666661111666666666666666dddd7777d2102222222222205742448200f700000175d77777777777f7777650d7cc
ddddddddddddddddddddd666666666666dddd6666666dddddd666666666ddddd777d0410420002222200e20244442d77000000750675577777766777767dd7c7
ddddddddddddddddddddddd666666666ddddddd666ddddddddddd6666ddddddd7650840024420022200e4002e44506770000007506677777776277777d66d7c7
ddddddddddddddddddddddd655555ddddddddddddddddddddddddddddddddddd774221002444222205e80002e44201dd0000006d0d6677777d067777d676d7c7
ddddddddddddddddddddddd5555555dddddddddddddddddddddddddddddddddd6500000004422200df820001444440050000006d0d716776500776d67777d777
ddddddddddddddddddddd55555555555ddddddddddd55dddddddddddddddd555000010000242201244420000444442050000006d05755d516006567777776c77
ddddddddd5555ddddddd5555555555555ddddddd5555555dddddddddd5555555100000000000000244422002e40244400000007d0d6600056300d67777777c77
dddd555555555555dd5555555555555555555555555555555dddd55555555555000000000000000044422005d50d777d00000176666ccd0d6d1d6777777777cc
dd5555555555555555555555555555555555555555555555555555555555555510000000000000002224200011056f670000057666ccccccc6667777777777c6
__map__
c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
011000000b14010040100400b14000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01140000100401004010040101400b140000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000b1471004710147100470b145151000b0000b100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000405003050020500105000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000003452515000150001500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01080000104341c434284343443400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800000415503155021550115500155000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a00001a0351a0351a0302803528030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000230341c035000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a00001c0341c035260352603426035260000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000346251c600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000002862300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001063300003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001003300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01100000106351c624000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0114000010142101420f1420e14200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01080000101550f1550e1550d1550c1550b1550a15509155081550715506155051550415500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800002804228042280322803226021260222601226012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000442504425044000442504425044250440004425044250442504400044250442504425044000442502425024250440002425024250242504400024250242502425044000242502425024250440002425
011000001003310000000001000028635000001000000000100331000000000100002863500000100330000010033100000000010000286350000010000000001003310033100331000028635100001003310033
011000001013010110101351013510130101100e1300e1101113011110111351113511135111350e1300e1101013010110101360e13610135101300e1300e1101713217132171351713711137111321113211132
01100000171321711217132171321713210110111301111018130181101813518136181351813511130111101013010110101351013510135101300e1300e110111321113211132111320c1350c1350e1350e135
011000000413504135041350413504135041350413504135041350413504135041350413504135041350413502135021350213502135021350213502135021350213502135021350213502135021350213502135
011000000013500135001350013500135001350013500135001350013500135001350013500135001350013502135021350213502135021350213502135021350213502135021350213502135021350213502135
01100000107301073010735107351073510735107301073017730177301773517735177351773518730187351573015730157351573515735157351873018730117351173511730117300e7350e7350e7350e735
01100000107301073010735107351073510735107301073017730177301773517735177351773518730187351a7301a7301a7351a7351a7351a73515730157300e7350e7350e7300e73011735117351173511735
0110000010730107301173511735107351073511730117301073010730107351073510735107350e7300e7351573015730157351573515735157351773017730187351873518730187301a7351a7351a7351a735
011000001073010730107301073011730117301173011730107301073010730107301173011730117301173010730107300e7300e7300c7300c73009730097300473004730047300473004730047300473004730
0110000010735107351073210735177351773517735177351a7351a7351a7321a7351c7351c7351c7351c73515735157351573215735237352373523735237352673526735267322673528732287322873228732
__music__
01 20212244
02 20212344
01 24264344
00 25274344
00 24264344
02 25284344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 60424344
__label__
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc88888888aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0000000000aaaaaaaaaaaaaaaaaaaaaaa8888888888888888888888888888888888cc
cc88888888aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0808000880aaaaaaaaaaaaaaaaaaaaaaa8888888888888888888888888888888888cc
cc88888888aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0880008080aaaaaaaaaaaaaaaaaaaaaaa8888888888888888888888888888888888cc
cc88888888aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0808008080aaaaaaaaaaaaaaaaaaaaaaa8888888888888888888888888888888888cc
cc88888888aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0808008800aaaaaaaaaaaaaaaaaaaaaaa8888888888888888888888888888888888cc
cc88888888aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0000000000aaaaaaaaaaaaaaaaaaaaaaa8888888888888888888888888888888888cc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111155555444444445111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111155499aaaaaaaaaaaaaaaaa1111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111111111115549aaaaaaaaaaaaaa99444444950111111111111111111111111111111111111111111111111
111111111111111111111111111111111111111111111111114aaaaa994454aaa950000000000001111111111111111111111111111111111111111111111111
11111111111111111111111111111151111111111111111114a944500000004aa500111111111111111111111111111111111111111111111111111111111111
1111111111111111111111111154aaa9a511545111111111150000011111114aa011111111154455511111111111111111111111111111111111111111111111
1111111111111111111111115aaaaaaaa9aa950111111111110111111111119aa011111111115aaaaa9451111111111111111111111111111111111111111111
11111111111111111111159aaaaaaaaaa940001111111111111111111111119a90111111111119aaaaaaaa511111111111111111111111111111111111111111
111111111111111111119aaaaaaaaaa4000011111111111111111111115111aa901111111111114a9549aaa51111111111111111111111111111111111111111
1111111111111111114aaaaaaaaa9500011111111149aa911154a111a99111aa411155544911114a900059a91111111111111111111111111111111111111111
11111111111111115aaaaaaaaa950001111111114aaaaa91114aa011aa90119a4119aaaaa901119a911114aa1111111111111111111111111111111111111111
1111111111111159aaaaa9aa4500111115111119a99aaa91119a90159a40159a411999994401119a411115995111111111111111155555511111111111111111
11111111111111aa99999a90001111115991114a9999500011999015994115995119900000111199511119990111111111544999999999999944444555511111
11111111111114a999999a001111111599a115999900011111994014994114995119901111151499415499990111111111aaaaaaaaaaaaaaaaaaaaaaa9451111
1111111111111999999999011111111499901499900111151199949999511499015941111114999999999990011111115aaaaaaaaaaaaaaaaaaaaaaa50001111
111111111111599995999901111511199990199950154999119999999901149901594154411199999999940011111115aaaaa9aaaaaa9aaaaa9999a501111111
1111111111114994009994115491111999411999011999990199999999011499014999994111999999999201111115555000005aaa4000aaa500000011111111
1111111111114940059994149994111999411999011499920199400999011499014999990111499900099911111111100001111aaa0011aa9011111111111111
1111111111114200159999999999115999211999011149401599011999011994014940000111499401149941111111111111114aa90115aa4011111111111111
1111111111111011149999999940012999011999411149401299011994011994014900111111889401129891111111111111119aa40119aa5111111111111111
111111111111111129999999420011499901149994249940129801199401189411880111111288821111888811111111111111aaa01119aa0111111111111111
111111111111111149999940001111499401118888988840148401188401288411882244411488801111488821111111111115aaa0115aa90111111111111111
111111111111111148884000111111488401112888888841148401288411288411888888411888801111288881111111111114aa90115aa50111111111111111
111111111111111148884011111111888401111248448841148401288411128411888888411888401111188884111111111119aa41114aa01111111111111111
11111111111111114888411111111188840111110000884118841148841111221142200000488821111114888811111111111aaa01119a901111111111111111
11111111111111111888211111111188841111111111884112841110421111101100000112844801111112824421111111115aaa0111aa401111111111111111
11111111111111112888211111111182841111111111000111001111001111101111111111000001111111400001111111114aa40114aa511111111111111111
11111111111111114888011111111100841111111111110111101111111111111111111111111111111111001111111111119aa51119aa011111111111111111
11111111111111111288011111111111001111111111111111111111111111111111111111111111111111111111111111119aa01119a9011111111111111111
1111111111111111102801111111111111111111111111111111111111111111111111111111111111111111111111111115aa90115aa4011111111111111111
1111111111111111111001111111111111111111111111111111111111111111111111111111111111111111111111111114aa40115aa0111111111111111111
11111111111111111111011111111111111111111111111111111111111111111111111111111111111111111111111111199a51114a90111111111111111111
111111111111111111111111111115549a5111111111111111111111111111111111111111111111111111111111111111199901119a40111111111111111111
1111111111111111111111111159aaaaaaa911111111111111111111111111111111111111111111111111111111111111599901159940111111111111111111
1111111111111111111111159aaaaaa9455001111111111111111111111111111111111111111111111111111111111111499401149901111111111111111111
1111111111111111111115aaaaaa95000001111111111111111155554449999aaaaaaaaaaaaaaaaa994455111111111111499211199901111111111111111111
111111111111111111119aaaaa50001111111111111155499aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa4511111111999011199401111111111111111111
1111111111111111115aaaaa400011111111115549aaaaaaaaaaaaaaaaaa999944445500015549aaa44999aaaa91111115999011599201111111111111111111
111111111111111114aaaaa0001111111115aaaaaaaaaaaaaaa999445000000000000000540004aa9000000059aa111112994011499011111111111111111111
11111111111111115aaaaa00111111111114aaaaaaaaa99445550000011115544911aaaaaa1119aa40111111109a411114992011499011111111111111111111
11111111111111119aaaaa0111111111115aaaa9aaa4000999aaa9511111aaaaaa11aa944001199901111111119a511114890111494011111111111111111111
1111111111111111aaaaaa4111111111119a4505aaa0011aaaa99aa911159a450001a90000115999011111154994011118880112884011111111111111111111
1111111111111115aaaaaaaaa945111111500014aa9011119a9005aa4115a9000015a95541115994011114999950111128840114880111111111111111111111
11111111111111114aaaaaaaaaaaa411111111199a5111119a401199911499449114999a90119990111149940001111148820114880111111111111111111111
1111111111111111149aaaaaa9999a91111111199901111499011599901499999014994500119990111155000111111148801118840111111111111111111111
1111111111111111110054499a9999a9111111599901111999554999001999400019920001159940111110111111111188801128820111111111111111111111
11111111111111111111100004999999111111499401119999999990011992001119901111149901111111111111111288401148801111111111111111111111
11111111111111111111111111499999411111999011114994444990111990111119922441199401111111111111111488201148801111111111111111111111
11111111111111111111111111599999411111999011114940000994115994444129999941199401111111111111112888211188801111111111111111111111
11111111111111111111111111999999011115994011119940111499114999994124444201542011111111111111128888422888822222111111111111111111
11111111111111111111111114999994011114990111149921111299412444200110000001100011111111144888888888888888888888884011111111111111
11111111111111111111111299999990011119990111144401111144411000000111111111111111111111488888888888888888888888882111111111111111
11111111111111111111114999999900111129940111110001111100001111111111111111111111111112888888888888888888888888884011111111111111
11111111111111111111499888894001111148400111111111111111111111111111111111111111112244422222000000000000000000000011111111111111
11111111111111111149988888840011111110001111111111111111111111111111111111111111111000000000000000111111111111111111111111111111
11111111111111248888888884000111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111112448888888888420011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111888888888842001111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111488888884200111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111148888420001111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111104840001111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111000111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555522255555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555222825555555555555555555555555555555555555
3333333333333333333333333333333333aaaa33333333333333333333333333333333333333333333333324e222233333333333333333333333333333333333
33333333333333333333333333333335ddaeaa33333333333333333333333333333333333333333333333332f222222333333333333333333333333333333333
333333333333333333333333333333d6ff6dfaa333553333333333333333c333c6676d333333333d226dd66d2d66333333333333333333333333333333333333
3333333333333333333333333333336efffff9af45433333333333333336ddc6766676c33333332f427f6fd6766d333333333333333333333333333333333333
333333333333333333333333333333d4e5eeefff405333333333333333d6cc6c66677763333333332333333d66ff333333333333333333333333333333333333
66666666666666666666666666666666e666ede40de666666666666666d7cc666667776666666666666666662d22266666666666666666666666666666666666
6666666666666666666666666666666666776566654666666666666666666dc676c666666666666666666666d624266666666666666666666666666666666666
666666666666666666666666666666dd666d6666665666666666666666666666d666c66666666666666666222722266666666666666666666666666666666666
0000000000000000000000000000d7660056500000000000000000000000000000000000000000000000444247d422d000000000000000000000000000000000
555555555555555555555555555d6d7655566776555555555555555555555555555555555555555555544444427ef22d55555555555555555555555555555555
55555555555555555555555555d677660d5d6666d55555555555555555555555555555555555555555542222227de42555555555555555555555555555555555
55555555555555555555555556677655055dd66655555555555555555555555555555555555555555554425552274fd555555555555555555555555555555555
55555555555555555555555d6666d5555555d6665555555555555555555555555555555555555555555d4555552224fd55555555555555555555555555555555
555555555555555555555556666d55555555d6765555555555555555555555555555555555555555555dd5555552552e65555555555555555555555555555555
555555555555555555555f466d5555555555545555555555555555555555555555555555555555555556d5555555555567d55555555555555555555555555555
555555555555555555554fe5555555555555ef55555555555555555555555555555555555555555555d72555555555555d7d5555555555555555555555555555
555555555555555555554e45555550000000e4ff555555555555555555555555555555555555555555d200000000005555555555555555555555555555555555
55555555555555555550000000000000000000000000055555555555500000000000000055555000000000000000000000000555555555555555555555555555
55555555555555555555555555555000000000005555555555555555555555555555555555555555550000000000005555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
__meta:title__
fighter street ii
by bitwise creative
