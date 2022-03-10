USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Автор:		  Денисов Алексей
Описание:
*/
ALTER PROCEDURE [dbo].[DISTR_FINANCING_PROCESS?Batch]
    @SaleObject_Id      SmallInt,
    @Document_Id        SmallInt,
    @Good_Id            SmallInt,
    @Unit_Id            SmallInt,
    @Default            Bit
AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		UPDATE dbo.DistrDocumentTable SET
            DD_ID_GOOD = @Good_Id,
            DD_ID_UNIT = @Unit_Id
        WHERE DD_ID_DOC = @Document_Id
            AND DD_ID_DISTR IN
                (
                    SELECT D.DIS_ID
                    FROM dbo.DistrView AS D WITH(NOEXPAND)
                    WHERE D.SYS_ID_SO = @SaleObject_Id
                );

        IF @Default = 1
            UPDATE dbo.DocumentSaleObjectDefaultTable SET
                DSD_ID_GOOD = @Good_Id,
                DSD_ID_UNIT = @Unit_Id
            WHERE DSD_ID_SO = @SaleObject_Id
                AND DSD_ID_DOC = @Document_Id;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[DISTR_FINANCING_PROCESS?Batch] TO rl_distr_financing_w;
GO
