USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[DISTR_BUH_CHANGE]
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

		DECLARE @NEW_DISTR TABLE (ID INT)

		-- вставка новых дистрибутивов в справочник
		INSERT INTO dbo.DistrTable(DIS_ID_SYSTEM, DIS_NUM, DIS_COMP_NUM, DIS_ACTIVE)
			OUTPUT inserted.DIS_ID INTO @NEW_DISTR
			SELECT SYS_ID, RN_DISTR_NUM, RN_COMP_NUM, 1
			FROM 
				dbo.DistrExchange
				INNER JOIN dbo.SystemTable a ON SYS_ID_HOST = NEW_HOST
				INNER JOIN dbo.RegNodeTable ON SYS_REG_NAME = RN_SYS_NAME 
											AND NEW_NUM = RN_DISTR_NUM
											AND NEW_COMP = RN_COMP_NUM
			WHERE NOT EXISTS
				(
					SELECT *
					FROM 
						dbo.DistrTable 
						INNER JOIN dbo.SystemTable b ON DIS_ID_SYSTEM = b.SYS_ID
					WHERE b.SYS_ID_HOST = a.SYS_ID_HOST
						AND DIS_NUM = RN_DISTR_NUM
						AND DIS_COMP_NUM = RN_COMP_NUM
				) AND RN_DISTR_TYPE <> 'NEK'

		-- распределить все эти дистрибутивы по клиентам
		INSERT INTO dbo.ClientDistrTable(CD_ID_CLIENT, CD_ID_DISTR, CD_ID_SERVICE)
			SELECT CD_ID_CLIENT, a.ID, (SELECT TOP 1 DSS_ID FROM dbo.DistrServiceStatusTable WHERE DSS_REPORT = 1)
			FROM 
				@NEW_DISTR a
				INNER JOIN dbo.DistrTable b ON a.ID = b.DIS_ID
				INNER JOIN dbo.SystemTable c ON c.SYS_ID = b.DIS_ID_SYSTEM
				INNER JOIN dbo.DistrExchange d ON d.NEW_HOST = c.SYS_ID_HOST
											AND d.NEW_NUM = b.DIS_NUM
											AND d.NEW_COMP = b.DIS_COMP_NUM
				INNER JOIN dbo.SystemTable e ON e.SYS_ID_HOST = d.OLD_HOST
				INNER JOIN dbo.DistrTable f ON f.DIS_ID_SYSTEM = e.SYS_ID
											AND f.DIS_NUM = d.OLD_NUM
											AND f.DIS_COMP_NUM = d.OLD_COMP
				INNER JOIN dbo.ClientDistrTable g ON g.CD_ID_DISTR = f.DIS_ID
			WHERE f.DIS_ACTIVE = 1

		-- распределить все эти дистрибутивы по точкам
		INSERT INTO dbo.TODistrTable(TD_ID_TO, TD_ID_DISTR)
			SELECT TD_ID_TO, a.ID
			FROM 
				@NEW_DISTR a
				INNER JOIN dbo.DistrTable b ON a.ID = b.DIS_ID
				INNER JOIN dbo.SystemTable c ON c.SYS_ID = b.DIS_ID_SYSTEM
				INNER JOIN dbo.DistrExchange d ON d.NEW_HOST = c.SYS_ID_HOST
											AND d.NEW_NUM = b.DIS_NUM
											AND d.NEW_COMP = b.DIS_COMP_NUM
				INNER JOIN dbo.SystemTable e ON e.SYS_ID_HOST = d.OLD_HOST
				INNER JOIN dbo.DistrTable f ON f.DIS_ID_SYSTEM = e.SYS_ID
											AND f.DIS_NUM = d.OLD_NUM
											AND f.DIS_COMP_NUM = d.OLD_COMP
				INNER JOIN dbo.TODistrTable g ON g.TD_ID_DISTR = f.DIS_ID
			WHERE f.DIS_ACTIVE = 1
				AND NOT EXISTS
					(
						SELECT *
						FROM dbo.TODistrTable z
						WHERE z.TD_ID_DISTR = b.DIS_ID
					)
			

		-- прицепить эти дистрибутивы в действующие договора, к которым цеплялись старые
		INSERT INTO dbo.ContractDistrTable(COD_ID_CONTRACT, COD_ID_DISTR)
			SELECT CO_ID, ID
			FROM
				(
					SELECT 
						(
							SELECT TOP 1 COD_ID_CONTRACT
							FROM 
								dbo.DistrTable b
								INNER JOIN dbo.SystemTable c ON b.DIS_ID_SYSTEM = c.SYS_ID
								INNER JOIN dbo.DistrExchange d ON d.NEW_HOST = c.SYS_ID_HOST
															AND d.NEW_NUM = b.DIS_NUM
															AND d.NEW_COMP = b.DIS_COMP_NUM
								INNER JOIN dbo.SystemTable e ON e.SYS_ID_HOST = OLD_HOST
								INNER JOIN dbo.DistrTable f ON f.DIS_ID_SYSTEM = e.SYS_ID
															AND f.DIS_NUM = OLD_NUM
															AND f.DIS_COMP_NUM = OLD_COMP
								INNER JOIN dbo.ClientDistrTable g ON g.CD_ID_DISTR = b.DIS_ID
								INNER JOIN dbo.ContractTable h ON h.CO_ID_CLIENT = g.CD_ID_CLIENT
								INNER JOIN dbo.ContractDistrTable i ON i.COD_ID_CONTRACT = h.CO_ID AND COD_ID_DISTR = f.DIS_ID
							WHERE a.ID = b.DIS_ID AND CO_ACTIVE = 1
							ORDER BY CO_DATE DESC
						) AS CO_ID
						, ID
					FROM @NEW_DISTR a
				) AS o_O
			WHERE CO_ID IS NOT NULL	

		-- сменить статус старых дистрибутивов
		UPDATE dbo.ClientDistrTable
		SET CD_ID_SERVICE = (SELECT DSS_ID FROM dbo.DistrServiceStatusTable WHERE DSS_NAME = 'недействующий')
		WHERE CD_ID_DISTR IN
			(
				SELECT a.DIS_ID
				FROM 
					dbo.DistrTable a
					INNER JOIN dbo.SystemTable b ON a.DIS_ID_SYSTEM = b.SYS_ID
					INNER JOIN dbo.DistrExchange c ON b.SYS_ID_HOST = OLD_HOST
												AND a.DIS_NUM = OLD_NUM
												AND a.DIS_COMP_NUM = OLD_COMP
					INNER JOIN dbo.SystemTable d ON d.SYS_ID_HOST = NEW_HOST
					INNER JOIN dbo.DistrTable e ON e.DIS_ID_SYSTEM = d.SYS_ID
												AND e.DIS_NUM = NEW_NUM
												AND e.DIS_COMP_NUM = NEW_COMP
					INNER JOIN @NEW_DISTR f ON e.DIS_ID = f.ID
			)


		INSERT INTO dbo.DistrFinancingTable(DF_ID_DISTR, DF_ID_NET, DF_ID_TECH_TYPE, DF_ID_TYPE, DF_ID_SCHEMA, DF_ID_PRICE, DF_DISCOUNT, DF_COEF, DF_FIXED_PRICE, DF_ID_PERIOD, DF_MON_COUNT, DF_ID_PAY, DF_DEBT)
			SELECT DISTINCT a.ID, DF_ID_NET, DF_ID_TECH_TYPE, DF_ID_TYPE, DF_ID_SCHEMA, DF_ID_PRICE, DF_DISCOUNT, DF_COEF, DF_FIXED_PRICE, DF_ID_PERIOD, DF_MON_COUNT, DF_ID_PAY, DF_DEBT
			FROM 
				@NEW_DISTR a
				INNER JOIN dbo.DistrTable b ON a.ID = b.DIS_ID
				INNER JOIN dbo.SystemTable c ON c.SYS_ID = b.DIS_ID_SYSTEM
				INNER JOIN dbo.DistrExchange d ON d.NEW_HOST = c.SYS_ID_HOST
											AND d.NEW_NUM = b.DIS_NUM
											AND d.NEW_COMP = b.DIS_COMP_NUM
				INNER JOIN dbo.SystemTable e ON e.SYS_ID_HOST = d.OLD_HOST
				INNER JOIN dbo.DistrTable f ON f.DIS_ID_SYSTEM = e.SYS_ID
											AND f.DIS_NUM = d.OLD_NUM
											AND f.DIS_COMP_NUM = d.OLD_COMP
				INNER JOIN dbo.DistrFinancingTable g ON g.DF_ID_DISTR = f.DIS_ID
			WHERE NOT EXISTS
				(
					SELECT *
					FROM dbo.DistrFinancingTable z
					WHERE z.DF_ID_DISTR = a.ID
				) AND f.DIS_ACTIVE = 1

		INSERT INTO dbo.DistrDocumentTable(DD_ID_DISTR, DD_ID_DOC, DD_PRINT, DD_ID_GOOD, DD_ID_UNIT, DD_PREFIX)
			SELECT DISTINCT a.ID, DD_ID_DOC, DD_PRINT, DD_ID_GOOD, DD_ID_UNIT, DD_PREFIX
			FROM 
				@NEW_DISTR a
				INNER JOIN dbo.DistrTable b ON a.ID = b.DIS_ID
				INNER JOIN dbo.SystemTable c ON c.SYS_ID = b.DIS_ID_SYSTEM
				INNER JOIN dbo.DistrExchange d ON d.NEW_HOST = c.SYS_ID_HOST
											AND d.NEW_NUM = b.DIS_NUM
											AND d.NEW_COMP = b.DIS_COMP_NUM
				INNER JOIN dbo.SystemTable e ON e.SYS_ID_HOST = d.OLD_HOST
				INNER JOIN dbo.DistrTable f ON f.DIS_ID_SYSTEM = e.SYS_ID
											AND f.DIS_NUM = d.OLD_NUM
											AND f.DIS_COMP_NUM = d.OLD_COMP
				INNER JOIN dbo.DistrDocumentTable g ON g.DD_ID_DISTR = f.DIS_ID
			WHERE NOT EXISTS
				(
					SELECT *
					FROM dbo.DistrDocumentTable z
					WHERE z.DD_ID_DISTR = a.ID
						AND z.DD_ID_DOC = g.DD_ID_DOC
				)	 AND f.DIS_ACTIVE = 1
				
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();
		
		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;
		
		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
