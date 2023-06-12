﻿USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Install].[INSTALL_DISTR_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Install].[INSTALL_DISTR_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [Install].[INSTALL_DISTR_SELECT]
	@DATE	SMALLDATETIME
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ID_FULL_DATE, CL_NAME, SYS_SHORT, IND_DISTR, IND_CONTRACT, CLM_DATE AS IND_CONTRACT_TS
	FROM
		Install.Install a
		INNER JOIN Install.InstallDetail b ON INS_ID = IND_ID_INSTALL
		INNER JOIN Income.IncomeDetail ON ID_ID = IND_ID_INCOME
		INNER JOIN Income.Incomes ON IN_ID = ID_ID_INCOME
		INNER JOIN Distr.SystemActive c ON SYS_ID_MASTER = IND_ID_SYSTEM
		INNER JOIN Distr.HostActive d ON HST_ID_MASTER = SYS_ID_HOST
		INNER JOIN Clients.ClientActive e ON CL_ID_MASTER = INS_ID_CLIENT

		INNER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.Hosts g ON g.HostReg = d.HST_REG AND HST_REG IS NOT NULL
		LEFT OUTER JOIN Claim.Claims ON CLM_ID = IND_ID_CLAIM
	WHERE IND_DISTR IS NOT NULL AND RTRIM(LTRIM(IND_DISTR)) <> ''
		AND IND_LOCK = 0 AND ID_LOCK = 0
		AND ID_REPAY = 0 AND ID_FULL_DATE IS NOT NULL
		AND (ID_FULL_DATE >= @DATE OR @DATE IS NULL)
		AND NOT EXISTS
		(
			SELECT *
			FROM
				[PC275-SQL\ALPHA].ClientDB.dbo.RegNodeTable z
				INNER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.SystemTable y ON y.SystemBaseName = z.SystemName
			WHERE y.HostID = g.HostID
				AND CHARINDEX('/', LTRIM(RTRIM(IND_DISTR))) = 0
				AND LTRIM(RTRIM(IND_DISTR)) = DistrNumber
				AND CompNumber = 1

			UNION ALL

			SELECT *
			FROM
				[PC275-SQL\ALPHA].ClientDB.dbo.RegNodeTable z
				INNER JOIN [PC275-SQL\ALPHA].ClientDB.dbo.SystemTable y ON y.SystemBaseName = z.SystemName
			WHERE y.HostID = g.HostID
				AND CHARINDEX('/', LTRIM(RTRIM(IND_DISTR))) <> 0
				AND LEFT(LTRIM(RTRIM(IND_DISTR)), CHARINDEX('/', LTRIM(RTRIM(IND_DISTR))) - 1) = DistrNumber
				AND RIGHT(LTRIM(RTRIM(IND_DISTR)), LEN(LTRIM(RTRIM(IND_DISTR))) - CHARINDEX('/', LTRIM(RTRIM(IND_DISTR)))) = CompNumber
		)
	ORDER BY IN_DATE DESC, CL_NAME, SYS_ORDER, IND_DISTR
END
GO
GRANT EXECUTE ON [Install].[INSTALL_DISTR_SELECT] TO rl_install_distr_report;
GO
