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
RETURNS @t TABLE							--������� ��� ���������� �������
	(
		InfoBankID			INT, 
		InfoBankName		NVARCHAR(50), 
		InfoBankShortName	NVARCHAR(50),
		PRIMARY KEY (InfoBankID)
	)
AS
BEGIN
	DECLARE @sys	TABLE					--������� � ������� � ��������� ���������
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
				DS_INDEX = 0

--��� ���� �������� ������� � SYS �� XML	



 
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
									WHERE InfoBankName IN ('QSOV', 'DOF')                           --�� ��������� �� ������� �������������� ������ ����� DOF � QSOV
								)
			)
	GROUP BY InfoBankID, InfoBankName, InfoBankShortName





--������� �� ������ ������ ��, ������� ������ ���� ������ ��� �����-�� �������

---------------------------------------------QSOV--------------------------------------------------------
	
	IF	(EXISTS(
			SELECT *
			FROM @sys
			WHERE	SystemBaseName IN ('LAW', 'BUD', 'BUDU', 'JUR', 'JURP') OR
					SystemBaseName IN ('SKJO', 'SKJP', 'SKJB', 'SBOO', 'SBOB') AND DistrTypeName IN ('���', '����') OR
					SystemBaseName IN ('SKJP', 'SBOO') AND DistrTypeName = '���-�(1;2)'
			
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





-----------------------------------------��������� ����, ����� � ���� �������� ������� ����� ���������------------------------

	DECLARE @DISTR			INT
	DECLARE @HOST			TINYINT
	DECLARE @COMP			TINYINT

	SELECT
		@DISTR = MainDistrNumber,
		@HOST = MainHostID,
		@COMP = MainCompNumber
	FROM
		dbo.RegNodeMainSystemView
	WHERE
		Complect = @COMPLECT
------------------------------------------------------------------------------------------------------------------------------


---------------------------------------------����������� �����, ������� ������ ���� � �������------------------------------------
	/*IF NOT EXISTS

						(
							SELECT UD_ID
							FROM USR.USRData
							WHERE
									UD_DISTR = @DISTR AND
									UD_ID_HOST = @HOST AND
									UD_COMP= @COMP
						)
			
	BEGIN
		DELETE FROM @t

		INSERT INTO @t
		VALUES(-1, '����������� USR', '����������� USR')

		RETURN
	END
*/

	DECLARE @rl_bnks	TABLE
	(
		InfoBankID	SMALLINT,
		PRIMARY KEY (InfoBankID)
	) 

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
----------------------------------------------------------------------------------------------------------------------------------


------------------------------------� ������ ��� ����� ���� ��� ������ ������� � ����������� �� ���������� � ���� RZB ��� ROS-----------------------------------------------------------------

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


-------------------------------������� �� ��� ������ ��� ������ ����, ��, ��� ��� ����-------------------------
	DELETE
	FROM @t
	WHERE InfoBankID IN
				(
					SELECT InfoBankID
					FROM @rl_bnks
				)
---------------------------------------------------------------------------------------------------------

	RETURN
END
