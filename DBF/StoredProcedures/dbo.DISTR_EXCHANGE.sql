USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:			Денисов Алексей/Богдан Владимир
Дата создания:  
Описание:
*/
ALTER PROCEDURE [dbo].[DISTR_EXCHANGE]
	@distrid INT,
	@newsysid INT
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

		INSERT INTO dbo.DistrDeliveryHistoryTable(DDH_ID_DISTR, DDH_ID_OLD_CLIENT, DDH_ID_NEW_CLIENT, DDH_NOTE, DDH_USER, DDH_DATE)
			SELECT
				@distrid,
				(SELECT CD_ID_CLIENT FROM dbo.ClientDistrTable WHERE CD_ID_DISTR = @distrid),
				(SELECT CD_ID_CLIENT FROM dbo.ClientDistrTable WHERE CD_ID_DISTR = @distrid),
				'Замена с ' + (SELECT SYS_SHORT_NAME FROM dbo.DistrView WITH(NOEXPAND) WHERE DIS_ID = @distrid) + ' на ' + (SELECT SYS_SHORT_NAME FROM dbo.SystemTable WHERE SYS_ID = @newsysid),
				ORIGINAL_LOGIN(), GETDATE()

		DECLARE @newid INT

		SELECT @newid = DIS_ID
		FROM dbo.DistrTable	a
		WHERE EXISTS
			(
				SELECT *
				FROM dbo.DistrTable b
				WHERE a.DIS_NUM = b.DIS_NUM
					AND a.DIS_COMP_NUM = b.DIS_COMP_NUM
					AND a.DIS_ID_SYSTEM = @newsysid
					AND b.DIS_ID = @distrid
			)

		IF @newid IS NULL
			BEGIN
				--Создаем новый дистрибутив
				INSERT INTO dbo.DistrTable(DIS_ID_SYSTEM, DIS_NUM, DIS_COMP_NUM, DIS_ACTIVE)
					SELECT @newsysid, DIS_NUM, DIS_COMP_NUM, 1
					FROM dbo.DistrTable
					WHERE DIS_ID = @distrid

				SELECT @newid = SCOPE_IDENTITY()
			END
		ELSE
			BEGIN
				UPDATE dbo.DistrTable
				SET DIS_ACTIVE = 1
				WHERE DIS_ID = @newid
			END

		UPDATE dbo.DistrTable
		SET DIS_ACTIVE = 0
		WHERE DIS_ID = @distrid


		INSERT INTO dbo.ClientDistrTable
			SELECT CD_ID_CLIENT, @newid, NULL, CD_ID_SERVICE
			FROM dbo.ClientDistrTable
			WHERE CD_ID_DISTR = @distrid


		INSERT INTO dbo.TODistrTable
			SELECT @newid, TD_ID_TO, TD_FORCED
			FROM dbo.TODistrTable
			WHERE TD_ID_DISTR = @distrid

		--Удалить все остальные дистрибутивы с таким же хостом и номером
		DELETE
		FROM dbo.TODistrTable
		WHERE TD_ID_DISTR = @distrid

		DELETE
		FROM dbo.ClientDistrTable
		WHERE CD_ID_DISTR = @distrid

		-- задать фин.установки для нового дистрибутива
		INSERT INTO dbo.DistrFinancingTable
				(
					DF_ID_DISTR, DF_ID_NET, DF_ID_TECH_TYPE, DF_ID_TYPE,
					DF_ID_PRICE, DF_DISCOUNT, DF_COEF, DF_FIXED_PRICE,
					DF_ID_PERIOD, DF_MON_COUNT
				)
			SELECT
				@newid, DF_ID_NET, DF_ID_TECH_TYPE, DF_ID_TYPE, DF_ID_PRICE,
				DF_DISCOUNT, DF_COEF, DF_FIXED_PRICE, DF_ID_PERIOD, DF_MON_COUNT
			FROM dbo.DistrFinancingTable
			WHERE DF_ID_DISTR = @distrid

		DELETE FROM dbo.DistrFinancingTable WHERE DF_ID_DISTR = @distrid

		INSERT INTO dbo.DistrDocumentTable
				(
					DD_ID_DISTR, DD_ID_DOC, DD_PRINT, DD_ID_GOOD, DD_ID_UNIT
				)
			SELECT @newid, DD_ID_DOC, DD_PRINT, DD_ID_GOOD, DD_ID_UNIT
			FROM dbo.DistrDocumentTable
			WHERE DD_ID_DISTR = @distrid
				AND NOT EXISTS
					(
						SELECT *
						FROM dbo.DistrDocumentTable
						WHERE DD_ID_DISTR = @newid
					)

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[DISTR_EXCHANGE] TO rl_client_distr_w;
GRANT EXECUTE ON [dbo].[DISTR_EXCHANGE] TO rl_distr_w;
GO