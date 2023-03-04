USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[EIS@Check]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[EIS@Check]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[EIS@Check]
    @Act_Id			Int,
	@Invoice_Id		Int
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

	DECLARE
		@Client_Id		Int,
		@ClientPsedo	VarChar(100);

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

    BEGIN TRY

		IF @Act_Id IS NOT NULL
			SELECT
				@Client_Id = [ACT_ID_CLIENT],
				@ClientPsedo = C.[CL_PSEDO]
			FROM [dbo].[ActTable] AS A
			INNER JOIN [dbo].[ClientTable] AS C ON c.[CL_ID] = A.[ACT_ID_CLIENT]
			WHERE [ACT_ID] = @Act_Id;

		IF @Invoice_Id IS NOT NULL
			SELECT
				@Client_Id = [INS_ID_CLIENT],
				@ClientPsedo = C.[CL_PSEDO]
			FROM [dbo].[InvoiceSaleTable] AS A
			INNER JOIN [dbo].[ClientTable] AS C ON c.[CL_ID] = A.[INS_ID_CLIENT]
			WHERE [INS_ID] = @Invoice_Id;


		IF NOT EXISTS
		(
			SELECT *
			FROM dbo.ClientFinancing AS CF
			WHERE CF.[ID_CLIENT] = @Client_Id
				AND EIS_CODE IS NOT NULL
				AND EIS_CODE != ''
		)
			RaisError('Для клиента "%s не указан код ЕИС', 16, 1, @ClientPsedo);

		IF NOT EXISTS
		(
			SELECT *
			FROM dbo.ClientFinancing AS CF
			WHERE CF.[ID_CLIENT] = @Client_Id
				AND EIS_DATA IS NOT NULL
				AND Cast(EIS_DATA AS VarChar(Max)) != ''
		)
			RaisError('Для клиента %s не загружены данные ЕИС', 16, 1, @ClientPsedo);

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [dbo].[EIS@Check] TO rl_act_p;
GO
