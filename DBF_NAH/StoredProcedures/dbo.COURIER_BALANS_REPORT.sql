USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[COURIER_BALANS_REPORT]
	@PR_ID INT,
	@COUR_ID varchar(MAX), --ID COUR(S)
	@resstatus TINYINT = 0 OUTPUT
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

		DECLARE @PR_ID_OLD SMALLINT

		DECLARE @COUR TABLE
			(
				COUR_ID INT
			)

		IF @COUR_ID IS NULL
			INSERT INTO @COUR(COUR_ID)
				SELECT COUR_ID FROM dbo.CourierTable WHERE COUR_ACTIVE = 1
		ELSE
			INSERT INTO @COUR(COUR_ID)
				SELECT * FROM dbo.GET_TABLE_FROM_LIST(@COUR_ID, ',')

		IF OBJECT_ID('tempdb..#o_reg_list') IS NOT NULL
			DROP TABLE #o_reg_list

		CREATE TABLE #o_reg_list
			(
				REG_DISTR_NUM int NULL,
				REG_COMP_NUM tinyint NULL,
				SYS_ID_HOST smallint NULL,
				REG_ID_COUR smallint NULL,
				REG_ID_SYSTEM smallint NULL,
				REG_ID_SYSTEM_OLD smallint NULL,
				REG_ID_STATUS smallint NULL,
				CHANGE_WEIGHT decimal (16,4) NULL,
				Oper varchar(100) NULL,
				REG_COMMENT VARCHAR(100)
			)
		 -- ÔÂ‰˚‰Û˘ËÈ ÔÂËÓ‰
			SELECT @PR_ID_OLD = PR_ID
			FROM dbo.PeriodTable
			WHERE PR_DATE = DATEADD(month, -1, (SELECT PR_DATE FROM dbo.PeriodTable P WHERE P.PR_ID = @PR_ID))

			IF (@PR_ID_OLD IS NULL)
			BEGIN
				SET @resstatus = -100
				RETURN
			END

			-- ‚˚ÍÎ->‚ÍÎ
			INSERT INTO #o_reg_list
			SELECT     P.[REG_DISTR_NUM]
					  ,P.[REG_COMP_NUM]
					  ,Q.[SYS_ID_HOST]
					  ,P.[REG_ID_COUR]
					  ,P.[REG_ID_SYSTEM] 
					  ,O.[REG_ID_SYSTEM] 
					  ,P.[REG_ID_STATUS]
					  ,0-(T.[SN_COEF] * S.[STW_WEIGHT])
					  ,'Œ“ Àﬁ◊≈Õ»≈'
					  ,P.REG_COMMENT
				  FROM [dbo].[PeriodRegTable] P
				  LEFT JOIN [dbo].[PeriodRegTable] O ON (O.[REG_ID_PERIOD]=@PR_ID_OLD)
					AND(O.[REG_ID_STATUS]=1)AND(O.[REG_DISTR_NUM]=P.[REG_DISTR_NUM])
					AND(O.[REG_COMP_NUM]=P.[REG_COMP_NUM])AND(O.[REG_ID_SYSTEM]=P.[REG_ID_SYSTEM])
				  LEFT JOIN [dbo].[SystemNetCountTable] N ON N.[SNC_ID]=P.[REG_ID_NET]
				  LEFT JOIN [dbo].[SystemNetTable] T ON T.[SN_ID]=N.[SNC_ID_SN]
				  LEFT JOIN [dbo].[SystemTypeWeightTable] S ON S.[STW_ID_SYSTEM]=P.[REG_ID_SYSTEM] AND S.[STW_ID_TYPE]=P.[REG_ID_TYPE]
				  LEFT JOIN [dbo].[SystemTable] Q ON Q.SYS_ID = S.[STW_ID_SYSTEM]
				  WHERE (P.[REG_ID_STATUS] = 2)AND(NOT(O.[REG_ID_SYSTEM] IS NULL))
						AND(P.[REG_ID_PERIOD]=@PR_ID)
						AND(P.[REG_ID_COUR] IN (SELECT * FROM @COUR))
			-- ‚ÍÎ->‚˚ÍÎ
			INSERT INTO #o_reg_list
			SELECT     P.[REG_DISTR_NUM]
					  ,P.[REG_COMP_NUM]
					  ,Q.[SYS_ID_HOST]
					  ,P.[REG_ID_COUR]
					  ,P.[REG_ID_SYSTEM] 
					  ,O.[REG_ID_SYSTEM] 
					  ,P.[REG_ID_STATUS]
					  ,T.[SN_COEF] * S.[STW_WEIGHT]
					  ,'¬ Àﬁ◊≈Õ»≈'
					  ,P.REG_COMMENT
				  FROM [dbo].[PeriodRegTable] P
				  LEFT JOIN [dbo].[PeriodRegTable] O ON (O.[REG_ID_PERIOD]=@PR_ID_OLD)
					AND(O.[REG_ID_STATUS]=2)AND(O.[REG_DISTR_NUM]=P.[REG_DISTR_NUM])
					AND(O.[REG_COMP_NUM]=P.[REG_COMP_NUM])AND(O.[REG_ID_SYSTEM]=P.[REG_ID_SYSTEM])
				  LEFT JOIN [dbo].[SystemNetCountTable] N ON N.[SNC_ID]=P.[REG_ID_NET]
				  LEFT JOIN [dbo].[SystemNetTable] T ON T.[SN_ID]=N.[SNC_ID_SN]
				  LEFT JOIN [dbo].[SystemTypeWeightTable] S ON S.[STW_ID_SYSTEM]=P.[REG_ID_SYSTEM] AND S.[STW_ID_TYPE]=P.[REG_ID_TYPE]
				  LEFT JOIN [dbo].[SystemTable] Q ON Q.[SYS_ID] = S.[STW_ID_SYSTEM]
				  WHERE (P.[REG_ID_STATUS] = 1)AND(NOT(O.[REG_ID_SYSTEM] IS NULL))
						AND(P.[REG_ID_PERIOD]=@PR_ID)
						AND(P.[REG_ID_COUR] IN (SELECT * FROM @COUR))
			-- ÔÓ‚˚¯ÂÌËÂ/ÔÓÌËÊÂÌËÂ
			INSERT INTO #o_reg_list
			SELECT     P.[REG_DISTR_NUM]
					  ,P.[REG_COMP_NUM]
					  ,Q.[SYS_ID_HOST]
					  ,P.[REG_ID_COUR]
					  ,P.[REG_ID_SYSTEM] 
					  ,O.[REG_ID_SYSTEM] 
					  ,P.[REG_ID_STATUS]
					  ,(T.[SN_COEF] * S.[STW_WEIGHT])-(T_O.[SN_COEF] * S_O.[STW_WEIGHT])
					  ,CASE
						  WHEN (((T.[SN_COEF] * S.[STW_WEIGHT])-(T_O.[SN_COEF] * S_O.[STW_WEIGHT]))>0) THEN
						  CASE
							WHEN (P.[REG_ID_SYSTEM] <> O.[REG_ID_SYSTEM]) THEN
							  CASE
								  WHEN T.[SN_COEF] = T_O.[SN_COEF] THEN 'œŒ¬€ÿ≈Õ»≈ '+' Ò ' + Q_O.[SYS_SHORT_NAME] +' Ì‡ '+Q.[SYS_SHORT_NAME]
								  ELSE 'œŒ¬€ÿ≈Õ»≈ '+' Ò ' + Q_O.[SYS_SHORT_NAME] +' Ì‡ '+Q.[SYS_SHORT_NAME] +' Ò ' + T_O.[SN_NAME] +' Ì‡ '+T.[SN_NAME]
                    		  END
							 ELSE 'œŒ¬€ÿ≈Õ»≈ ' +' Ò ' + T_O.[SN_NAME] +' Ì‡ '+T.[SN_NAME]
						  END
						  WHEN (((T.[SN_COEF] * S.[STW_WEIGHT])-(T_O.[SN_COEF] * S_O.[STW_WEIGHT]))<0) THEN
						  CASE
							WHEN (P.[REG_ID_SYSTEM] <> O.[REG_ID_SYSTEM]) THEN
							  CASE
								  WHEN T.[SN_COEF] = T_O.[SN_COEF] THEN 'œŒÕ»∆≈Õ»≈ '+' Ò ' + Q_O.[SYS_SHORT_NAME] +' Ì‡ '+Q.[SYS_SHORT_NAME]
								  ELSE 'œŒÕ»∆≈Õ»≈ '+' Ò ' + Q_O.[SYS_SHORT_NAME] +' Ì‡ '+Q.[SYS_SHORT_NAME] +' Ò ' + T_O.[SN_NAME] +' Ì‡ '+T.[SN_NAME]
                    		  END
							 ELSE 'œŒÕ»∆≈Õ»≈' +' Ò ' + T_O.[SN_NAME] +' Ì‡ '+T.[SN_NAME]
						  END
					   END
					,P.REG_COMMENT
				  FROM [dbo].[PeriodRegTable] P
				  LEFT JOIN [dbo].[SystemTypeWeightTable] S ON S.[STW_ID_SYSTEM]=P.[REG_ID_SYSTEM] AND S.[STW_ID_TYPE]=P.[REG_ID_TYPE]
				  LEFT JOIN [dbo].[SystemTable] Q ON Q.[SYS_ID] = S.[STW_ID_SYSTEM]
				  LEFT JOIN [dbo].[PeriodRegTable] O ON (O.[REG_ID_PERIOD]=@PR_ID_OLD)
					AND(O.[REG_ID_STATUS]=P.[REG_ID_STATUS])AND(O.[REG_DISTR_NUM]=P.[REG_DISTR_NUM])
					AND(O.[REG_COMP_NUM]=P.[REG_COMP_NUM])AND(O.[REG_ID_SYSTEM] in (SELECT [SYS_ID]
					FROM [dbo].[SystemTable] WHERE [SYS_ID_HOST] = Q.[SYS_ID_HOST]))
				  LEFT JOIN [dbo].[SystemNetCountTable] N ON N.[SNC_ID]=P.[REG_ID_NET]
				  LEFT JOIN [dbo].[SystemNetTable] T ON T.[SN_ID]=N.[SNC_ID_SN]
				  LEFT JOIN [dbo].[SystemNetCountTable] N_O ON N_O.[SNC_ID]=O.[REG_ID_NET]
				  LEFT JOIN [dbo].[SystemNetTable] T_O ON T_O.[SN_ID]=N_O.[SNC_ID_SN]
				  LEFT JOIN [dbo].[SystemTypeWeightTable] S_O ON S_O.[STW_ID_SYSTEM]=O.[REG_ID_SYSTEM] AND S_O.[STW_ID_TYPE]=O.[REG_ID_TYPE]
				  LEFT JOIN [dbo].[SystemTable] Q_O ON Q_O.[SYS_ID] = S_O.[STW_ID_SYSTEM]
				  WHERE (((T.[SN_COEF] * S.[STW_WEIGHT])-(T_O.[SN_COEF] * S_O.[STW_WEIGHT]))<>0)AND(P.[REG_ID_STATUS] = 1)AND(NOT(O.[REG_ID_SYSTEM] IS NULL))
						AND(P.[REG_ID_PERIOD]=@PR_ID)
						AND(P.[REG_ID_COUR] IN (SELECT * FROM @COUR))


		SELECT
			COUR_ID, COUR_NAME,
			REG_COMMENT,
			--SYS_SHORT_NAME,
			SYS_ORDER,
			SYS_SHORT_NAME + ' ' + CONVERT(VARCHAR(20), REG_DISTR_NUM) +
				CASE REG_COMP_NUM
					WHEN 1 THEN ''
					ELSE '/' + CONVERT(VARCHAR(20), REG_COMP_NUM)
				END AS DIS_STR,
			--SYS_ID_HOST smallint NULL,
			--REG_ID_COUR smallint NULL,
			--REG_ID_SYSTEM smallint NULL,
			--REG_ID_SYSTEM_OLD smallint NULL,
			--REG_ID_STATUS smallint NULL,
			CHANGE_WEIGHT,
			Oper
		FROM
			#o_reg_list INNER JOIN
			dbo.CourierTable ON COUR_ID = REG_ID_COUR INNER JOIN
			dbo.SystemTable ON SYS_ID = REG_ID_SYSTEM
		order by COUR_NAME, REG_COMMENT, SYS_ORDER, Oper

		IF OBJECT_ID('tempdb..#o_reg_list') IS NOT NULL
			DROP TABLE #o_reg_list

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
GRANT EXECUTE ON [dbo].[COURIER_BALANS_REPORT] TO rl_courier_balans;
GO
