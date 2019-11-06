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
		PRIMARY KEY (InfoBankID)
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
	)
	
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
		INNER JOIN dbo.DistrTypeTable ON DistrTypeId = Net_Id
--¬Œ“ —ﬁƒ¿ ¬€√–”« ” “¿¡À»÷€ ¬ SYS »« XML	
	


 
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
	
	IF	(EXISTS(
			SELECT *
			FROM @sys
			WHERE	SystemBaseName IN ('LAW', 'BUD', 'BUDU', 'JUR', 'JURP') OR
					SystemBaseName IN ('SKJO', 'SKJP', 'SKJB', 'SBOO', 'SBOB') AND DistrTypeName IN ('ÎÓÍ', 'ÙÎ˝¯') OR
					SystemBaseName IN ('SKJP', 'SBOO') AND DistrTypeName = 'Œ¬Ã-‘(1;2)'
			
			)AND
		EXISTS(
			SELECT *
			FROM @sys
			WHERE SystemBaseName = 'FIN' OR SystemBaseName = 'QSA'
								)
			)

		DELETE FROM @t
		WHERE InfoBankName = 'QSOV'

---------------------------------------------------------------------------------------------------------



---------------------------------------------DOF--------------------------------------------------------

	IF (EXISTS(
		SELECT * 
		FROM @sys
		WHERE SystemBaseName = 'LAW'
			)AND
		NOT EXISTS(
		SELECT *
		FROM @sys
		WHERE SystemBaseName IN ('FIN', 'KOR', 'BORG', 'QSA', 'CMT')
			)
		)

		DELETE FROM @t
		WHERE InfoBankName = 'DOF'

---------------------------------------------------------------------------------------------------------





-----------------------------------------¬€◊»—Àﬂ≈Ã ’Œ—“, ƒ»—“– »  ŒÃœ Œ—ÕŒ¬ÕŒ… —»—“≈Ã€ ›“Œ√Œ  ŒÃœÀ≈ “¿------------------------

	DECLARE @DISTR			INT
	DECLARE @HOST			TINYINT
	DECLARE @COMP			TINYINT

	SELECT
		@DISTR = MainDistrNumber,
		@HOST = MainHostID,
		@COMP = MainCompNumber
	FROM
		dbo.RegNodeMainSystemView WITH(NOEXPAND)
	WHERE
		Complect = @COMPLECT
------------------------------------------------------------------------------------------------------------------------------


---------------------------------------------¬€“¿— »¬¿≈Ã ¡¿Õ »,  Œ“Œ–€≈ —≈…◊¿— ≈—“‹ ¬ —»—“≈Ã≈------------------------------------
	DECLARE @rl_bnks	TABLE
	(
		InfoBankID	SMALLINT,
		PRIMARY KEY (InfoBankID)
	) 

	IF @SYS_NET_XML IS NULL
		INSERT INTO @rl_bnks
		SELECT UI_ID_BASE
		FROM USR.USRIB
		WHERE UI_ID_USR = 
				(
					SELECT UF_ID
					FROM USR.USRActiveView 
					WHERE UD_ID = 
							(
								SELECT UD_ID
								FROM USR.USRData
								WHERE
										UD_DISTR = @DISTR AND
										UD_ID_HOST = @HOST AND
										UD_COMP= @COMP
							)
				)
	ELSE
		INSERT INTO @rl_bnks
		SELECT InfoBank_Id
		FROM
		(
			SELECT
				InfoBank_Id = c.value('@InfoBank_Id[1]',	'SmallInt')
			FROM @SYS_NET_XML.nodes('/ROOT/INFO_BANKS/ITEM') A(C)
		) X
----------------------------------------------------------------------------------------------------------------------------------


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
			WHERE InfoBankID = 
						(
							SELECT InfoBankID
							FROM dbo.InfoBankTable
							WHERE InfoBankName = 'RZB'
						)
		)	AND
		NOT EXISTS
			(
				SELECT InfoBankID
				FROM @rl_bnks
				WHERE InfoBankID = 
						(
							SELECT InfoBankID
							FROM dbo.InfoBankTable
							WHERE InfoBankName = 'ROS'
						)			
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
				WHERE InfoBankID = 
						(
							SELECT InfoBankID
							FROM dbo.InfoBankTable
							WHERE InfoBankName = 'ROS'
						)			
			)	AND
		NOT EXISTS
			(
				SELECT InfoBankID
				FROM @rl_bnks
				WHERE InfoBankID = 
						(
							SELECT InfoBankID
							FROM dbo.InfoBankTable
							WHERE InfoBankName = 'RZB'
						)			
			)
			DELETE
			FROM @t
			WHERE InfobankName IN (	'PBUN', 'PKBO', 'QSBO', 'RZB')
	END
---------------------------------------------------------------------------------------------------------------
	RETURN
END
