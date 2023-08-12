USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ComplectGetBanks]', 'TF') IS NULL EXEC('CREATE FUNCTION [dbo].[ComplectGetBanks] () RETURNS @output TABLE(Id Int) AS BEGIN RETURN END')
GO
CREATE OR ALTER FUNCTION [dbo].[ComplectGetBanks]
(
	@COMPLECT		NVARCHAR(50),
	@SYS_NET_XML	XML	= NULL
)
RETURNS @t TABLE							--ТАБЛИЦА ДЛЯ ИДЕАЛЬНОГО СОСТАВА
	(
		InfoBankID			INT,
		InfoBankName		NVARCHAR(50),
		InfoBankShortName	NVARCHAR(50),
		PRIMARY KEY (InfoBankID),
		UNIQUE(InfoBankName)
	)
AS
BEGIN
	DECLARE @sys	TABLE					--ТАБЛИЦА С ДАННЫМИ С СИСТЕМАМИ КОМПЛЕКТА
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
		SELECT DISTINCT SystemID, SystemBaseName, DistrTypeID, DistrTypeName
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

	-----------------------------------------ВЫЧИСЛЯЕМ ХОСТ, ДИСТР И КОМП ОСНОВНОЙ СИСТЕМЫ ЭТОГО КОМПЛЕКТА------------------------
	SELECT TOP(1)
		@DISTR = Cast(MainDistrNumber AS Int),
		@HOST = MainHostID,
		@COMP = Cast(MainCompNumber AS TinyInt)
	FROM dbo.RegNodeMainDistrView WITH(NOEXPAND)
	WHERE Complect = @COMPLECT;
	------------------------------------------------------------------------------------------------------------------------------

	---------------------------------------------ВЫТАСКИВАЕМ БАНКИ, КОТОРЫЕ СЕЙЧАС ЕСТЬ В СИСТЕМЕ------------------------------------
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
									WHERE InfoBankName IN ('QSOV', 'DOF')                           --НЕ ПРОВЕРЯТЬ НА НАЛИЧИЕ НЕОБЯЗАТЕЛЬНЫХ БАНКОВ КРОМЕ DOF И QSOV
								)
						AND s.SystemBaseName NOT LIKE 'SPK%'
			)
	GROUP BY InfoBankID, InfoBankName, InfoBankShortName


	--УДАЛЯЕМ ИЗ СПИСКА СИСТЕМ ТЕ, КОТОРЫЕ ДОЛЖНЫ БЫТЬ ТОЛЬКО ПРИ КАКОМ-ТО УСЛОВИИ
	---------------------------------------------QSOV--------------------------------------------------------

	IF	EXISTS
			(
				SELECT *
				FROM @sys
				WHERE	SystemBaseName IN ('LAW', 'BUD', 'BUDU', 'JUR', 'JURP')
					OR	SystemBaseName IN ('SKJO', 'SKJP', 'SKJB', 'SBOO', 'SBOB') AND DistrTypeName IN ('лок', 'флэш')
					OR	SystemBaseName IN ('SKJP', 'SBOO') AND DistrTypeName = 'ОВМ-Ф(1;2)'

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

	------------------------------------У систем СПК может быть два разных состава в зависимости от содержания в себе RZB или ROS-----------------------------------------------------------------
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

	------Удаляем подчиненные ИБ----
	--TODO: зависимости ИБ должны быть в настройках ИБ
	DELETE T
	FROM @t T
	WHERE	(T.InfoBankName = 'DOCS' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('ROS', 'RZB', 'RZR', 'LAW')))
		OR	(T.InfoBankName = 'ROS' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('RZB', 'RZR', 'LAW')))
		OR	(T.InfoBankName = 'RZB' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('RZR', 'LAW')))
		OR	(T.InfoBankName = 'RZR' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('LAW')))
		OR	(T.InfoBankName = 'DOF' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('PAPB', 'PAP')))
		OR	(T.InfoBankName = 'PAPB' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('PAP')))
		OR	(T.InfoBankName = 'RBAS020' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('RLBR020', 'RLAW020')))
		OR	(T.InfoBankName = 'RLBR020' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('RLAW020')))
		OR	(T.InfoBankName = 'EPB' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('EXPZ', 'EXP')))
		OR	(T.InfoBankName = 'EXPZ' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('EXP')))
		OR	(T.InfoBankName = 'PNPB' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('PNPA')))
		OR	(T.InfoBankName = 'PRJB' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('PRJ')))
		OR	(T.InfoBankName = 'OTNZ' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('OTN')))
		OR	(T.InfoBankName = 'ESUZ' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('ESU')))
		OR	(T.InfoBankName = 'CJIB' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('CJI')))
		OR	(T.InfoBankName = 'CMBB' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('CMB')))
		OR	(T.InfoBankName = 'PBIB' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('PBI')))
		OR	(T.InfoBankName = 'BRB' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('ARBB', 'ARB')))
		OR	(T.InfoBankName = 'ARBB' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('ARB')))
		OR	(T.InfoBankName = 'BCN' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('NCN', 'ACN', 'SCN')))
		OR	(T.InfoBankName = 'NCN' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('ACN', 'SCN')))
		OR	(T.InfoBankName = 'ACN' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('SCN')))
		OR	(T.InfoBankName = 'BDV' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('NDV', 'ADV', 'SDV')))
		OR	(T.InfoBankName = 'NDV' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('ADV', 'SDV')))
		OR	(T.InfoBankName = 'ADV' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('SDV')))
		OR	(T.InfoBankName = 'BMS' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('NMS', 'AMS', 'SMS')))
		OR	(T.InfoBankName = 'NMS' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('AMS', 'SMS')))
		OR	(T.InfoBankName = 'AMS' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('SMS')))
		OR	(T.InfoBankName = 'BPV' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('NPV', 'APV', 'SPV')))
		OR	(T.InfoBankName = 'NPV' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('APV', 'SPV')))
		OR	(T.InfoBankName = 'APV' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('SPV')))
		OR	(T.InfoBankName = 'BSK' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('NSK', 'ASK', 'SSK')))
		OR	(T.InfoBankName = 'NSK' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('ASK', 'SSK')))
		OR	(T.InfoBankName = 'ASK' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('SSK')))
		OR	(T.InfoBankName = 'BSZ' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('NSZ', 'ASZ', 'SSZ')))
		OR	(T.InfoBankName = 'NSZ' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('ASZ', 'SSZ')))
		OR	(T.InfoBankName = 'ASZ' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('SSZ')))
		OR	(T.InfoBankName = 'BUR' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('NUR', 'AUR', 'SUR')))
		OR	(T.InfoBankName = 'NUR' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('AUR', 'SUR')))
		OR	(T.InfoBankName = 'AUR' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('SUR')))
		OR	(T.InfoBankName = 'BVS' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('NVS', 'AVS', 'SVS')))
		OR	(T.InfoBankName = 'NVS' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('AVS', 'SVS')))
		OR	(T.InfoBankName = 'AVS' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('SVS')))
		OR	(T.InfoBankName = 'BVV' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('NVV', 'AVV', 'SVV')))
		OR	(T.InfoBankName = 'NVV' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('AVV', 'SVV')))
		OR	(T.InfoBankName = 'AVV' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('SVV')))
		OR	(T.InfoBankName = 'BZS' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('NZS', 'AZS', 'SZS')))
		OR	(T.InfoBankName = 'NZS' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('AZS', 'SZS')))
		OR	(T.InfoBankName = 'AZS' AND EXISTS (SELECT * FROM @t P WHERE P.InfoBankName IN ('SZS')))
		OR	(T.InfoBankName = 'DOF' AND NOT EXISTS (SELECT * FROM @t P WHERE P.InfoBankName NOT IN ('DOF')));

	RETURN
END

GO
