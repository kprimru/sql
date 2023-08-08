USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ACT_PRINT_CLEAR]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[ACT_PRINT_CLEAR]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[ACT_PRINT_CLEAR]
    @ActDate    SmallDateTime
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT;

    BEGIN TRY

        UPDATE dbo.ActTable SET
			ACT_PRINT = 0,
			ACT_PRINT_DATE = NULL
		WHERE ACT_DATE = @ActDate;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[ACT_PRINT_CLEAR] TO rl_act_p;
GO
