USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[REPORT_INCOME_PURPOSE]
    @Date               SmallDateTime,
    @Organization_Id    SmallInt = NULL
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

        SELECT
            C.[CL_ID], C.[CL_PSEDO], C.[CL_FULL_NAME],
            I.[IN_DATE], I.[IN_PAY_NUM],
            D.[Purpose], CC.[COUR_NAME]
        FROM [dbo].[IncomeTable] AS I
        INNER JOIN [Raw].[Incomes:Details] AS D ON I.[Raw_Id] = D.[Id]
        INNER JOIN [dbo].[ClientTable] AS C ON C.[CL_ID] = I.[IN_ID_CLIENT]
        OUTER APPLY
        (
            SELECT TOP (1) CC.[COUR_NAME]
            FROM [dbo].[ClientCourView] AS CC
            WHERE CC.[CL_ID] = C.[CL_ID]
        ) AS CC
        WHERE I.[IN_DATE] >= @Date
            AND (I.[IN_ID_ORG] = @Organization_Id OR @Organization_Id IS NULL)
        ORDER BY CC.[COUR_NAME], C.[CL_PSEDO];

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[REPORT_INCOME_PURPOSE] TO rl_report_income_r;
GO
