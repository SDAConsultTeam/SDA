select 
CompnyName,
adm1.Street,
adm1.Block,
adm1.City,
adm1.County,
adm1.ZipCode,
ADM1.StreetF,
adm1.BlockF,
adm1.CityF,
adm1.CountyF,AliasName,Phone1,IntrntAdrs,RevOffice,
CASE WHEN adm1.GlblLocNum = '00000' THEN N'(Head office)'
  WHEN adm1.GlblLocNum <> '00000' THEN N'(Branch ' + adm1.GlblLocNum+')'
  END as 'GLN_H'
from oadm,adm1,ADM2