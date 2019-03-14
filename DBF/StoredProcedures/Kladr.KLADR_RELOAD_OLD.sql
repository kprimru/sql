USE [DBF]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [Kladr].[KLADR_RELOAD]
AS
BEGIN
	SET NOCOUNT ON;

	IF EXISTS
		(
			SELECT srvname 
			FROM master.dbo.sysservers 
			WHERE srvname='KladrData'
		) 
		EXEC sp_dropserver @server='KladrData', @droplogins='droplogins' 

	EXEC sp_addlinkedserver @server = N'KladrData', 
							@srvproduct=N'MicrosoftJet.OLEDB.4.0', 
							@provider=N'Microsoft.Jet.OLEDB.4.0', 
							@datasrc=N'E:\KLADR\', 
							@provstr=N'dBase 5.0'

	EXEC sp_addlinkedsrvlogin 'KladrData', 'false', 'sa', 'admin'

	TRUNCATE TABLE Kladr.Altnames

	EXEC('
	INSERT INTO Kladr.Altnames (KA_OLDCODE, KA_NEWCODE, KA_LEVEL)
	SELECT OLDCODE, NEWCODE, LEVEL FROM KladrData...ALTNAMES')

	TRUNCATE TABLE Kladr.Doma

	EXEC('
	INSERT INTO Kladr.Doma (KD_NAME, KD_KORP, KD_SOCR, KD_CODE, KD_INDEX, KD_GNINMB, KD_UNO, KD_OCATD)
	SELECT NAME, KORP, SOCR, CODE, [INDEX], GNINMB, UNO, OCATD FROM KladrData...DOMA')

	TRUNCATE TABLE Kladr.Flat

	EXEC('
	INSERT INTO Kladr.Flat (KF_NAME, KF_CODE, KF_INDEX, KF_GNINMB, KF_UNO, KF_NP)
	SELECT NAME, CODE, [INDEX], GNINMB, UNO, NP FROM KladrData...FLAT')

	TRUNCATE TABLE Kladr.Kladr

	EXEC('
	INSERT INTO Kladr.Kladr (KL_NAME, KL_SOCR, KL_CODE, KL_INDEX, KL_GNINMB, KL_UNO, KL_OCATD, KL_STATUS)
	SELECT NAME,SOCR,CODE,[INDEX],GNINMB,UNO,OCATD,STATUS FROM KladrData...KLADR')

	TRUNCATE TABLE Kladr.Socrbase

	EXEC('
	INSERT INTO Kladr.Socrbase (KSB_LEVEL, KSB_SCNAME, KSB_SOCRNAME, KSB_KOD)
	SELECT LEVEL, SCNAME, SOCRNAME, KOD_T_ST FROM KladrData...SOCRBASE')

	TRUNCATE TABLE Kladr.Street

	EXEC('
	INSERT INTO Kladr.Street (KS_NAME, KS_SOCR, KS_CODE, KS_INDEX, KS_GNINMB, KS_UNO, KS_OCATD)
	SELECT NAME,SOCR,CODE,[INDEX],GNINMB,UNO,OCATD FROM KladrData...STREET')

	EXEC sp_droplinkedsrvlogin 'KladrData', 'sa'
	EXEC sp_dropserver 'KladrData'

	EXEC Kladr.KLADR_TREE_CREATE
END