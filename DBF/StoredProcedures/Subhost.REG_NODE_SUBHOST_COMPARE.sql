USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Subhost].[REG_NODE_SUBHOST_COMPARE]
	@PR_ID	SMALLINT,
	@SH_ID	SMALLINT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		DECLARE @PR_PREV SMALLINT

		SELECT @PR_PREV = dbo.PERIOD_PREV(@PR_ID)

		IF OBJECT_ID('tempdb..#rn') IS NOT NULL
			DROP TABLE #rn

		CREATE TABLE #rn
			(
				ID INT IDENTITY(1, 1) PRIMARY KEY,
				REG_ID_HST SMALLINT,
				REG_ID_SYSTEM SMALLINT,
				REG_DISTR_NUM INT,
				REG_COMP_NUM TINYINT,
				REG_ID_NET SMALLINT,
				REG_ID_HOST SMALLINT,
				REG_OPER VARCHAR(100),
				REG_COMMENT VARCHAR(500),
				REG_ID_TYPE SMALLINT,
				REG_OLD_SYS SMALLINT,
				REG_NEW_SYS SMALLINT,
				REG_OLD_NET SMALLINT,
				REG_NEW_NET SMALLINT,
				REG_CHECKED BIT DEFAULT 0
			)

		--1. Новые системы
		INSERT INTO #rn
				(
					REG_ID_HST, REG_ID_SYSTEM, REG_DISTR_NUM, REG_COMP_NUM,
					REG_ID_NET, REG_ID_HOST,
					REG_OPER, REG_COMMENT, REG_ID_TYPE,
					REG_OLD_SYS, REG_NEW_SYS, REG_OLD_NET, REG_NEW_NET
				)
			SELECT
				SYS_ID_HOST, SYS_ID, REG_DISTR_NUM, REG_COMP_NUM,
				SN_ID, SH_ID, 'Новая система', REG_COMMENT,
				REG_ID_TYPE, NULL, NULL, NULL, NULL
			FROM
				dbo.PeriodRegTable a INNER JOIN
				dbo.SystemTable b ON a.REG_ID_SYSTEM = b.SYS_ID INNER JOIN
				dbo.SystemNetCountTable ON SNC_ID = REG_ID_NET INNER JOIN
				dbo.SystemNetTable ON SN_ID = SNC_ID_SN INNER JOIN
				dbo.SubhostTable ON SH_ID = REG_ID_HOST
			WHERE (SH_ID = @SH_ID OR @SH_ID IS NULL)
				AND REG_ID_PERIOD = @PR_ID
				AND NOT EXISTS
					(
						SELECT *
						FROM
							dbo.PeriodRegTable z INNER JOIN
							dbo.SystemTable y ON z.REG_ID_SYSTEM = y.SYS_ID
						WHERE z.REG_DISTR_NUM = a.REG_DISTR_NUM
							AND z.REG_COMP_NUM = a.REG_COMP_NUM
							AND b.SYS_ID_HOST = y.SYS_ID_HOST
							AND z.REG_ID_PERIOD = @PR_PREV
					)
				AND NOT EXISTS
					(
						SELECT *
						FROM dbo.DistrExchange
						WHERE b.SYS_ID_HOST = NEW_HOST
							AND a.REG_DISTR_NUM = NEW_NUM
							AND a.REG_COMP_NUM = NEW_COMP
					)


		INSERT INTO #rn
				(
					REG_ID_HST, REG_ID_SYSTEM, REG_DISTR_NUM, REG_COMP_NUM,
					REG_ID_NET, REG_ID_HOST,
					REG_OPER, REG_COMMENT, REG_ID_TYPE,
					REG_OLD_SYS, REG_NEW_SYS, REG_OLD_NET, REG_NEW_NET
				)
			SELECT
				e.SYS_ID_HOST, e.SYS_ID, d.REG_DISTR_NUM, d.REG_COMP_NUM,
				k.SN_ID, SH_ID,
				CASE
					WHEN (b.SYS_ID = e.SYS_ID) AND (h.SN_ID <> k.SN_ID) THEN 'с ' + k.SN_NAME + ' на ' + h.SN_NAME
					WHEN (b.SYS_ID <> e.SYS_ID) AND (h.SN_ID = k.SN_ID) THEN 'с ' + b.SYS_SHORT_NAME + ' на ' + e.SYS_SHORT_NAME
					WHEN (b.SYS_ID <> e.SYS_ID) AND (h.SN_ID <> k.SN_ID) THEN 'с ' + b.SYS_SHORT_NAME + ' ' + k.SN_NAME + ' на ' + e.SYS_SHORT_NAME + ' ' + h.SN_NAME
					ELSE 'Ошибка!!!'
				END, d.REG_COMMENT,
				d.REG_ID_TYPE,
				CASE
					WHEN b.SYS_ID <> e.SYS_ID THEN a.REG_ID_SYSTEM
					ELSE NULL
				END,
				CASE
					WHEN b.SYS_ID <> e.SYS_ID THEN d.REG_ID_SYSTEM
					ELSE NULL
				END,
				CASE
					WHEN h.SN_ID <> k.SN_ID THEN k.SN_ID
					ELSE NULL
				END,
				CASE
					WHEN h.SN_ID <> k.SN_ID THEN h.SN_ID
					ELSE NULL
				END
			FROM
				dbo.PeriodRegTable a INNER JOIN
				dbo.SystemTable b ON a.REG_ID_SYSTEM = b.SYS_ID INNER JOIN
				dbo.HostTable c ON c.HST_ID = SYS_ID_HOST INNER JOIN
				dbo.SystemNetCountTable j ON j.SNC_ID = REG_ID_NET INNER JOIN
				dbo.SystemNetTable k ON k.SN_ID = j.SNC_ID_SN INNER JOIN

				dbo.PeriodRegTable d ON d.REG_DISTR_NUM = a.REG_DISTR_NUM
								AND d.REG_COMP_NUM = a.REG_COMP_NUM INNER JOIN
							dbo.SubhostTable ON SH_ID = d.REG_ID_HOST INNER JOIN
				dbo.SystemTable e ON e.SYS_ID = d.REG_ID_SYSTEM INNER JOIN
				dbo.HostTable f ON f.HST_ID = e.SYS_ID_HOST AND c.HST_ID = f.HST_ID	INNER JOIN
				dbo.SystemNetCountTable g ON g.SNC_ID = d.REG_ID_NET INNER JOIN
				dbo.SystemNetTable h ON h.SN_ID = g.SNC_ID_SN
			WHERE d.REG_ID_PERIOD = @PR_ID
				AND a.REG_ID_PERIOD = @PR_PREV
				AND (SH_ID = @SH_ID OR @SH_ID IS NULL)
				AND (b.SYS_ID <> e.SYS_ID OR h.SN_ID <> k.SN_ID)

			UNION ALL

			SELECT
				e.SYS_ID_HOST, e.SYS_ID, d.REG_DISTR_NUM, d.REG_COMP_NUM,
				k.SN_ID, SH_ID,
				CASE
					WHEN (b.SYS_ID = e.SYS_ID) AND (h.SN_ID <> k.SN_ID) THEN 'с ' + k.SN_NAME + ' на ' + h.SN_NAME
					WHEN (b.SYS_ID <> e.SYS_ID) AND (h.SN_ID = k.SN_ID) THEN 'с ' + b.SYS_SHORT_NAME + ' на ' + e.SYS_SHORT_NAME
					WHEN (b.SYS_ID <> e.SYS_ID) AND (h.SN_ID <> k.SN_ID) THEN 'с ' + b.SYS_SHORT_NAME + ' ' + k.SN_NAME + ' на ' + e.SYS_SHORT_NAME + ' ' + h.SN_NAME
					ELSE 'Ошибка!!!'
				END, d.REG_COMMENT,
				d.REG_ID_TYPE,
				CASE
					WHEN b.SYS_ID <> e.SYS_ID THEN a.REG_ID_SYSTEM
					ELSE NULL
				END,
				CASE
					WHEN b.SYS_ID <> e.SYS_ID THEN d.REG_ID_SYSTEM
					ELSE NULL
				END,
				CASE
					WHEN h.SN_ID <> k.SN_ID THEN k.SN_ID
					ELSE NULL
				END,
				CASE
					WHEN h.SN_ID <> k.SN_ID THEN h.SN_ID
					ELSE NULL
				END
			FROM
				dbo.PeriodRegTable a INNER JOIN
				dbo.SystemTable b ON a.REG_ID_SYSTEM = b.SYS_ID INNER JOIN
				--dbo.HostTable c ON c.HST_ID = SYS_ID_HOST INNER JOIN
				dbo.SystemNetCountTable j ON j.SNC_ID = REG_ID_NET INNER JOIN
				dbo.SystemNetTable k ON k.SN_ID = j.SNC_ID_SN INNER JOIN
				dbo.SubhostTable ON SH_ID = REG_ID_HOST INNER JOIN
				dbo.DistrExchange p ON OLD_HOST = b.SYS_ID_HOST
									AND OLD_NUM = a.REG_DISTR_NUM
									AND OLD_COMP = a.REG_COMP_NUM INNER JOIN
				dbo.SystemTable e ON NEW_HOST = e.SYS_ID_HOST INNER JOIN
				dbo.PeriodRegTable d ON d.REG_DISTR_NUM = NEW_NUM
								AND d.REG_COMP_NUM = NEW_COMP
								AND e.SYS_ID = d.REG_ID_SYSTEM INNER JOIN
				--dbo.HostTable f ON f.HST_ID = e.SYS_ID_HOST INNER JOIN
				dbo.SystemNetCountTable g ON g.SNC_ID = d.REG_ID_NET INNER JOIN
				dbo.SystemNetTable h ON h.SN_ID = g.SNC_ID_SN
			WHERE d.REG_ID_PERIOD = @PR_ID
				AND a.REG_ID_PERIOD = @PR_PREV
				AND (SH_ID = @SH_ID OR @SH_ID IS NULL)
				AND (b.SYS_ID <> e.SYS_ID OR h.SN_ID <> k.SN_ID)
				AND (
						CASE
							WHEN b.SYS_REG_NAME = 'BUH' AND e.SYS_REG_NAME = 'BUHL' THEN 0
							WHEN b.SYS_REG_NAME = 'BUHU' AND e.SYS_REG_NAME = 'BUHUL' THEN 0
							ELSE 1
						END
					) = 1
				AND NOT EXISTS
					(
						SELECT *
						FROM dbo.PeriodRegTable z
						WHERE z.REG_DISTR_NUM = d.REG_DISTR_NUM
							AND z.REG_COMP_NUM = d.REG_COMP_NUM
							AND z.REG_ID_PERIOD = @PR_PREV
					)

		SELECT
			ID, b.SYS_ID, b.SYS_SHORT_NAME, REG_DISTR_NUM, REG_COMP_NUM,
			b.SYS_SHORT_NAME + ' ' + CONVERT(VARCHAR(20), REG_DISTR_NUM) +
			CASE REG_COMP_NUM
				WHEN 1 THEN ''
				ELSE '/' + CONVERT(VARCHAR(20), REG_COMP_NUM)
			END AS DIS_STR,
			SST_ID, SST_CAPTION,
			c.SN_ID, c.SN_NAME,
			SH_ID, SH_SHORT_NAME, REG_OPER, REG_COMMENT, REG_CHECKED,
			REG_OLD_SYS, REG_NEW_SYS, REG_OLD_NET, REG_NEW_NET,
			d.SN_NAME AS REG_OLD_NET_NAME, e.SN_NAME AS REG_NEW_NET_NAME,
			f.SYS_SHORT_NAME AS REG_OLD_SYS_NAME, g.SYS_SHORT_NAME AS REG_NEW_SYS_NAME,
			NULL AS REG_OLD_TECH, NULL AS REG_NEW_TECH
		FROM
			#rn a INNER JOIN
			dbo.HostTable ON HST_ID = REG_ID_HST INNER JOIN
			dbo.SystemTable b ON b.SYS_ID = a.REG_ID_SYSTEM INNER JOIN
			dbo.SystemNetTable c ON c.SN_ID = a.REG_ID_NET INNER JOIN
			dbo.SubhostTable ON SH_ID = REG_ID_HOST INNER JOIN
			dbo.SystemTypeTable ON SST_ID = REG_ID_TYPE LEFT OUTER JOIN
			dbo.SystemNetTable d ON d.SN_ID = REG_OLD_NET LEFT OUTER JOIN
			dbo.SystemNetTable e ON e.SN_ID = REG_NEW_NET LEFT OUTER JOIN
			dbo.SystemTable f ON f.SYS_ID = REG_OLD_SYS LEFT OUTER JOIN
			dbo.SystemTable g ON g.SYS_ID = REG_NEW_SYS
		WHERE NOT EXISTS
			(
				SELECT *
				FROM Subhost.RegNodeSubhostTable b
				WHERE a.REG_ID_SYSTEM = b.RNS_ID_SYSTEM
					AND a.REG_ID_HOST = b.RNS_ID_HOST
					AND @PR_ID = b.RNS_ID_PERIOD
					AND a.REG_DISTR_NUM = b.RNS_DISTR
					AND a.REG_COMP_NUM = b.RNS_COMP
			)
		ORDER BY SH_SHORT_NAME, b.SYS_ORDER, REG_DISTR_NUM, REG_COMP_NUM

		DROP TABLE #rn

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [Subhost].[REG_NODE_SUBHOST_COMPARE] TO rl_subhost_calc;
GO
