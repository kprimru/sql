﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Distr].[DISTR_INSTALL_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Distr].[DISTR_INSTALL_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Distr].[DISTR_INSTALL_SELECT]
	@EXCHANGE	BIT,
	@SYS		UNIQUEIDENTIFIER,
	@TYPE		UNIQUEIDENTIFIER,
	@NET		UNIQUEIDENTIFIER,
	@TECH		UNIQUEIDENTIFIER,
	@IND_ID		UNIQUEIDENTIFIER = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SYS_TYPE TABLE(ID UNIQUEIDENTIFIER)

	INSERT INTO @SYS_TYPE(ID)
		SELECT @TYPE

	IF @TYPE = '0E3CB75E-0FBA-DF11-B163-000C2986905F'
		INSERT INTO @SYS_TYPE(ID)
			VALUES('A17D355F-8202-E011-B173-000C2986905F')

	IF @TYPE = 'A17D355F-8202-E011-B173-000C2986905F'
		INSERT INTO @SYS_TYPE(ID)
			VALUES('0E3CB75E-0FBA-DF11-B163-000C2986905F')

	IF @TYPE = '103CB75E-0FBA-DF11-B163-000C2986905F'
		INSERT INTO @SYS_TYPE(ID)
			VALUES('1C3CB75E-0FBA-DF11-B163-000C2986905F')

	IF @TYPE = '1C3CB75E-0FBA-DF11-B163-000C2986905F'
		INSERT INTO @SYS_TYPE(ID)
			VALUES('103CB75E-0FBA-DF11-B163-000C2986905F')

	IF @TYPE = '163CB75E-0FBA-DF11-B163-000C2986905F'
		INSERT INTO @SYS_TYPE(ID)
			VALUES('103CB75E-0FBA-DF11-B163-000C2986905F')

	IF @TYPE = '103CB75E-0FBA-DF11-B163-000C2986905F'
		INSERT INTO @SYS_TYPE(ID)
			VALUES('163CB75E-0FBA-DF11-B163-000C2986905F')

	/*
	SELECT *
	FROM Distr.DistrTypeActive
	*/

	DECLARE @SYSTEM TABLE(ID UNIQUEIDENTIFIER)

	INSERT INTO @SYSTEM(ID)
		SELECT @SYS

	IF @SYS = '23E9B41E-ABE1-E111-8DB4-000C2986905F'
		INSERT INTO @SYSTEM(ID)
			VALUES('9C3BB75E-0FBA-DF11-B163-000C2986905F')
	IF @SYS = '9C3BB75E-0FBA-DF11-B163-000C2986905F'
		INSERT INTO @SYSTEM(ID)
			VALUES('23E9B41E-ABE1-E111-8DB4-000C2986905F')
	IF @SYS = '6828712A-ABE1-E111-8DB4-000C2986905F'
		INSERT INTO @SYSTEM(ID)
			VALUES('A23BB75E-0FBA-DF11-B163-000C2986905F')
	IF @SYS = 'A23BB75E-0FBA-DF11-B163-000C2986905F'
		INSERT INTO @SYSTEM(ID)
			VALUES('6828712A-ABE1-E111-8DB4-000C2986905F')

	IF @EXCHANGE = 0
		SELECT a.ID, a.ID AS ID_MASTER, CONVERT(VARCHAR(20), NUM) + CASE COMP WHEN 1 THEN '' ELSE '/' + CONVERT(VARCHAR(20), COMP) END AS DIS_STR, NUM, COMP
		FROM
			Distr.DistrIncome a
			INNER JOIN Distr.NetAll b ON a.ID_NET = b.ID
		WHERE ID_TYPE IN (SELECT ID FROM @SYS_TYPE)
			AND ID_SYSTEM IS NOT NULL
			AND ID_NET IS NOT NULL
			AND ID_SYSTEM IN (SELECT ID FROM @SYSTEM)
			AND EXISTS
				(
					SELECT *
					FROM
						Distr.NetTypeActive z
						CROSS JOIN Distr.TechTypeActive y
					WHERE y.TT_REG = b.TECH AND
						b.COEF = CASE TT_REG WHEN 0 THEN NT_COEF ELSE TT_COEF END
						AND z.NT_ID_MASTER = @NET
						AND y.TT_ID_MASTER = @TECH
				)
			AND PROCESS_DATE IS NULL

		UNION

		SELECT a.ID, a.ID AS ID_MASTER, CONVERT(VARCHAR(20), NUM) + CASE COMP WHEN 1 THEN '' ELSE '/' + CONVERT(VARCHAR(20), COMP) END AS DIS_STR, NUM, COMP
		FROM
			Distr.DistrIncome a
			INNER JOIN Install.InstallDetail ON IND_ID_DISTR = a.ID
		WHERE IND_ID = @IND_ID

		ORDER BY NUM, COMP
	ELSE IF @EXCHANGE = 1
		SELECT a.ID, a.ID AS ID_MASTER, CONVERT(VARCHAR(20), NUM) + CASE COMP WHEN 1 THEN '' ELSE '/' + CONVERT(VARCHAR(20), COMP) END AS DIS_STR, NUM, COMP
		FROM
			Distr.DistrIncome a
			INNER JOIN Distr.NetAll b ON (a.ID_NET = b.ID OR a.ID_NEW_NET = b.ID)
		WHERE ID_TYPE IN (SELECT ID FROM @SYS_TYPE)
			AND (ID_SYSTEM IS NULL OR ID_NET IS NULL)
			AND ((ID_SYSTEM IN (SELECT ID FROM @SYSTEM) AND ID_NEW_SYS IS NULL) OR (ID_NEW_SYS IN (SELECT ID FROM @SYSTEM) AND ID_SYSTEM IS NULL))
			AND EXISTS
				(
					SELECT *
					FROM
						Distr.NetTypeActive z
						CROSS JOIN Distr.TechTypeActive y
					WHERE /*y.TT_REG = b.TECH AND */
						b.COEF = CASE TT_REG WHEN 0 THEN NT_COEF ELSE TT_COEF END
						AND z.NT_ID_MASTER = @NET
						AND y.TT_ID_MASTER = @TECH
				)
			AND (
				PROCESS_DATE IS NULL
				AND ISNULL(ID_SUBHOST, 'f6329b50-489b-e211-8eed-000c2933b2fd') = 'f6329b50-489b-e211-8eed-000c2933b2fd'
				/*
				OR
				PROCESS_DATE IS NOT NULL
				--AND Common.DateOf(DATEADD(DAY, -3, GETDATE())) <= Common.DateOf(PROCESS_DATE)

				*/
				)


		UNION

		SELECT a.ID, a.ID AS ID_MASTER, CONVERT(VARCHAR(20), NUM) + CASE COMP WHEN 1 THEN '' ELSE '/' + CONVERT(VARCHAR(20), COMP) END AS DIS_STR, NUM, COMP
		FROM
			Distr.DistrIncome a
			INNER JOIN Install.InstallDetail ON IND_ID_DISTR = a.ID
		WHERE IND_ID = @IND_ID

		ORDER BY NUM, COMP
END
GO
GRANT EXECUTE ON [Distr].[DISTR_INSTALL_SELECT] TO rl_distr_income_r;
GO
