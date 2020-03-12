USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ComplectGetBanks]
(	
	@COMPLECT		NVARCHAR(50),
	@SYS_NET_XML	XML	= NULL
)
RETURNS @t TABLE							--“¿¡À»÷¿ ƒÀﬂ »ƒ≈¿À‹ÕŒ√Œ —Œ—“¿¬¿
	(
		InfoBankID			INT, 
		InfoBankName		NVARCHAR(50), 
		InfoBankShortName	NVARCHAR(50),
		PRIMARY KEY (InfoBankID),
		UNIQUE(InfoBankName)
	)
AS
BEGIN
	DECLARE @sys	TABLE					--“¿¡À»÷¿ — ƒ¿ÕÕ€Ã» — —»—“≈Ã¿Ã»  ŒÃœÀ≈ “¿
	(
		SystemID		INT,
		SystemBaseName	NVARCHAR(50),
		DistrTypeID		INT,
		DistrTypeName	NVARCHAR(50),
		PRIMARY KEY (SystemID, DistrTypeID)
	);

	DECLARE @rl_bnks	TABLE
	(
		InfoBankID	SMALLINT,
		PRIMARY KEY (InfoBankID)
	);
	
	DECLARE
		@ROS_IB			SmallInt,
		@RZB_IB			SmallInt,
		----
		@DISTR			INT,
		@HOST			TINYINT,
		@COMP			TINYINT;
	
	IF @SYS_NET_XML IS NULL
		INSERT INTO @sys
		SELECT SystemID, SystemBaseName, DistrTypeID, DistrTypeName
		FROM Reg.RegNodeSearchView WITH(NOEXPAND)
		WHERE	Complect = @COMPLECT AND
				DS_REG = 0
	ELSE
		INSERT INTO @sys
		SELECT SystemID, SystemBaseName, DistrTypeID, DistrTypeName
		FROM
		(
			SELECT
				Sys_Id = c.value('@Sys_Id[1]',	'SmallInt'),
				Net_Id = c.value('@Net_Id[1]',	'SmallInt')
			FROM @SYS_NET_XML.nodes('/ROOT/SYSTEMS/ITEM') A(C)
		) X
		INNER JOIN dbo.SystemTable ON Sys_Id = SystemId
		INNER JOIN dbo.DistrTypeTable ON DistrTypeId = Net_Id;

	-----------------------------------------¬€◊»—Àﬂ≈Ã ’Œ—“, ƒ»—“– »  ŒÃœ Œ—ÕŒ¬ÕŒ… —»—“≈Ã€ ›“Œ√Œ  ŒÃœÀ≈ “¿------------------------
	SELECT TOP(1)
		@DISTR = Cast(MainDistrNumber AS Int),
		@HOST = MainHostID,
		@COMP = Cast(MainCompNumber AS TinyInt)
	FROM dbo.RegNodeMainDistrView WITH(NOEXPAND)
	WHERE Complect = @COMPLECT;
	------------------------------------------------------------------------------------------------------------------------------

	---------------------------------------------¬€“¿— »¬¿≈Ã ¡¿Õ »,  Œ“Œ–€≈ —≈…◊¿— ≈—“‹ ¬ —»—“≈Ã≈------------------------------------
	IF @SYS_NET_XML IS NULL
		INSERT INTO @rl_bnks
		SELECT UI_ID_BASE
		FROM USR.USRActiveView U
		INNER JOIN USR.USRIB I ON U.UF_ID = I.UI_ID_USR
		WHERE UD_DISTR = @DISTR
			AND UD_ID_HOST = @HOST
			AND UD_COMP = @COMP
	ELSE
		INSERT INTO @rl_bnks
		SELECT InfoBank_Id
		FROM
		(
			SELECT
				InfoBank_Id = c.value('@InfoBank_Id[1]',	'SmallInt')
			FROM @SYS_NET_XML.nodes('/ROOT/INFO_BANKS/ITEM') A(C)
		) X;
	----------------------------------------------------------------------------------------------------------------------------------
 
	SET @ROS_IB = (SELECT InfoBankID FROM dbo.InfoBankTable WHERE InfoBankName = 'ROS');
	SET @RZB_IB = (SELECT InfoBankID FROM dbo.InfoBankTable WHERE InfoBankName = 'RZB');
 
	INSERT INTO @t
	SELECT InfoBankID, InfoBankName, InfoBankShortName
	FROM dbo.InfoBankTable
	WHERE InfoBankID IN
			(
				SELECT InfoBank_ID
				FROM dbo.SystemsBanks sb
				INNER JOIN @sys s ON sb.System_Id = s.SystemID AND sb.DistrType_Id = s.DistrTypeID
				WHERE	sb.Required = 1 OR
						sb.InfoBank_ID IN 
								(
									SELECT InfoBankID
									FROM dbo.InfoBankTable
									WHERE InfoBankName IN ('QSOV', 'DOF')                           --Õ≈ œ–Œ¬≈–ﬂ“‹ Õ¿ Õ¿À»◊»≈ Õ≈Œ¡ﬂ«¿“≈À‹Õ€’ ¡¿Õ Œ¬  –ŒÃ≈ DOF » QSOV
								)
			)
	GROUP BY InfoBankID, InfoBankName, InfoBankShortName


	--”ƒ¿Àﬂ≈Ã »« —œ»— ¿ —»—“≈Ã “≈,  Œ“Œ–€≈ ƒŒÀ∆Õ€ ¡€“‹ “ŒÀ‹ Œ œ–»  ¿ ŒÃ-“Œ ”—ÀŒ¬»»
	---------------------------------------------QSOV--------------------------------------------------------
	
	IF	EXISTS
			(
				SELECT *
				FROM @sys
				WHERE	SystemBaseName IN ('LAW', 'BUD', 'BUDU', 'JUR', 'JURP')
					OR	SystemBaseName IN ('SKJO', 'SKJP', 'SKJB', 'SBOO', 'SBOB') AND DistrTypeName IN ('ÎÓÍ', 'ÙÎ˝¯')
					OR	SystemBaseName IN ('SKJP', 'SBOO') AND DistrTypeName = 'Œ¬Ã-‘(1;2)'
			
			)
		AND EXISTS
			(
				SELECT *
				FROM @sys
				WHERE SystemBaseName = 'FIN' OR SystemBaseName = 'QSA'
			)
		DELETE FROM @t
		WHERE InfoBankName = 'QSOV';
	---------------------------------------------------------------------------------------------------------

	---------------------------------------------DOF--------------------------------------------------------
	IF EXISTS
			(
				SELECT * 
				FROM @sys
				WHERE SystemBaseName = 'LAW'
			)
		AND NOT EXISTS
			(
				SELECT *
				FROM @sys
				WHERE SystemBaseName IN ('FIN', 'KOR', 'BORG', 'QSA', 'CMT')
			)
		DELETE FROM @t
		WHERE InfoBankName = 'DOF';
	---------------------------------------------------------------------------------------------------------

	------------------------------------” ÒËÒÚÂÏ —œ  ÏÓÊÂÚ ·˚Ú¸ ‰‚‡ ‡ÁÌ˚ı ÒÓÒÚ‡‚‡ ‚ Á‡‚ËÒËÏÓÒÚË ÓÚ ÒÓ‰ÂÊ‡ÌËˇ ‚ ÒÂ·Â RZB ËÎË ROS-----------------------------------------------------------------
	IF EXISTS
		(
			SELECT *
			FROM @sys
			WHERE SystemBaseName IN ('SPK-I', 'SPK-II', 'SPK-III', 'SPK-IV', 'SPK-V')
		)
	BEGIN
		IF EXISTS 
			(
				SELECT InfoBankID
				FROM @rl_bnks
				WHERE InfoBankID = @RZB_IB
			)
		AND NOT EXISTS
			(
				SELECT InfoBankID
				FROM @rl_bnks
				WHERE InfoBankID = @ROS_IB	
			)
			DELETE
			FROM @t
			WHERE InfoBankName IN (	'QSA', 'PKS', 'ROS', 'PPS', 'CJIB',
									'PSP', 'PKV', 'PPN', 'PDR', 'PKP', 'PGU',
									'PTS', 'PSG', 'PKG', 'SIP', 'PPVS', 'ARBB',
									'PBIB', 'CMBB', 'CJB')

	ELSE IF EXISTS 
			(
				SELECT InfoBankID
				FROM @rl_bnks
				WHERE InfoBankID = @ROS_IB			
			)	AND
		NOT EXISTS
			(
				SELECT InfoBankID
				FROM @rl_bnks
				WHERE InfoBankID = @RZB_IB		
			)
			DELETE
			FROM @t
			WHERE InfobankName IN (	'PBUN', 'PKBO', 'QSBO', 'RZB')
	END
	---------------------------------------------------------------------------------------------------------------
	
	------”‰‡ÎˇÂÏ ÔÓ‰˜ËÌÂÌÌ˚Â »¡----
	DELETE T FROM @t T WHERE T.InfoBankName = 'DOCS' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('ROS', 'RZB', 'RZR', 'LAW'));
	DELETE T FROM @t T WHERE T.InfoBankName = 'ROS' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('RZB', 'RZR', 'LAW'));
	DELETE T FROM @t T WHERE T.InfoBankName = 'RZB' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('RZR', 'LAW'));
	DELETE T FROM @t T WHERE T.InfoBankName = 'RZR' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('LAW'));
	
	DELETE T FROM @t T WHERE T.InfoBankName = 'DOF' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('PAPB', 'PAP'));
	DELETE T FROM @t T WHERE T.InfoBankName = 'PAPB' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('PAP'));
	
	DELETE T FROM @t T WHERE T.InfoBankName = 'RBAS020' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('RLBR020', 'RLAW020'));
	DELETE T FROM @t T WHERE T.InfoBankName = 'RLBR020' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('RLAW020'));
	
	DELETE T FROM @t T WHERE T.InfoBankName = 'EPB' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('EXPZ', 'EXP'));
	DELETE T FROM @t T WHERE T.InfoBankName = 'EXPZ' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('EXP'));
	
	DELETE T FROM @t T WHERE T.InfoBankName = 'PNPB' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('PNPA'));
	
	DELETE T FROM @t T WHERE T.InfoBankName = 'PRJB' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('PRJ'));
	
	DELETE T FROM @t T WHERE T.InfoBankName = 'OTNZ' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('OTN'));
	
	DELETE T FROM @t T WHERE T.InfoBankName = 'ESUZ' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('ESU'));
	
	DELETE T FROM @t T WHERE T.InfoBankName = 'CJIB' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('CJI'));
	
	DELETE T FROM @t T WHERE T.InfoBankName = 'CMBB' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('CMB'));
	
	DELETE T FROM @t T WHERE T.InfoBankName = 'PBIB' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('PBI'));
	
	DELETE T FROM @t T WHERE T.InfoBankName = 'BRB' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('ARBB', 'ARB'));
	DELETE T FROM @t T WHERE T.InfoBankName = 'ARBB' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('ARB'));
	
	DELETE T FROM @t T WHERE T.InfoBankName = 'BCN' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('NCN', 'ACN', 'SCN'));
	DELETE T FROM @t T WHERE T.InfoBankName = 'NCN' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('ACN', 'SCN'));
	DELETE T FROM @t T WHERE T.InfoBankName = 'ACN' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('SCN'));
	
	DELETE T FROM @t T WHERE T.InfoBankName = 'BDV' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('NDV', 'ADV', 'SDV'));
	DELETE T FROM @t T WHERE T.InfoBankName = 'NDV' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('ADV', 'SDV'));
	DELETE T FROM @t T WHERE T.InfoBankName = 'ADV' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('SDV'));
	
	DELETE T FROM @t T WHERE T.InfoBankName = 'BMS' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('NMS', 'AMS', 'SMS'));
	DELETE T FROM @t T WHERE T.InfoBankName = 'NMS' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('AMS', 'SMS'));
	DELETE T FROM @t T WHERE T.InfoBankName = 'AMS' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('SMS'));
	
	DELETE T FROM @t T WHERE T.InfoBankName = 'BPV' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('NPV', 'APV', 'SPV'));
	DELETE T FROM @t T WHERE T.InfoBankName = 'NPV' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('APV', 'SPV'));
	DELETE T FROM @t T WHERE T.InfoBankName = 'APV' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('SPV'));
	
	DELETE T FROM @t T WHERE T.InfoBankName = 'BSK' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('NSK', 'ASK', 'SSK'));
	DELETE T FROM @t T WHERE T.InfoBankName = 'NSK' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('ASK', 'SSK'));
	DELETE T FROM @t T WHERE T.InfoBankName = 'ASK' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('SSK'));
	
	DELETE T FROM @t T WHERE T.InfoBankName = 'BSZ' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('NSZ', 'ASZ', 'SSZ'));
	DELETE T FROM @t T WHERE T.InfoBankName = 'NSZ' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('ASZ', 'SSZ'));
	DELETE T FROM @t T WHERE T.InfoBankName = 'ASZ' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('SSZ'));
	
	DELETE T FROM @t T WHERE T.InfoBankName = 'BUR' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('NUR', 'AUR', 'SUR'));
	DELETE T FROM @t T WHERE T.InfoBankName = 'NUR' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('AUR', 'SUR'));
	DELETE T FROM @t T WHERE T.InfoBankName = 'AUR' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('SUR'));
	
	DELETE T FROM @t T WHERE T.InfoBankName = 'BVS' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('NVS', 'AVS', 'SVS'));
	DELETE T FROM @t T WHERE T.InfoBankName = 'NVS' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('AVS', 'SVS'));
	DELETE T FROM @t T WHERE T.InfoBankName = 'AVS' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('SVS'));
	
	DELETE T FROM @t T WHERE T.InfoBankName = 'BVV' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('NVV', 'AVV', 'SVV'));
	DELETE T FROM @t T WHERE T.InfoBankName = 'NVV' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('AVV', 'SVV'));
	DELETE T FROM @t T WHERE T.InfoBankName = 'AVV' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('SVV'));
	
	DELETE T FROM @t T WHERE T.InfoBankName = 'BZS' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('NZS', 'AZS', 'SZS'));
	DELETE T FROM @t T WHERE T.InfoBankName = 'NZS' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('AZS', 'SZS'));
	DELETE T FROM @t T WHERE T.InfoBankName = 'AZS' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('SZS'));
	
	RETURN
END

