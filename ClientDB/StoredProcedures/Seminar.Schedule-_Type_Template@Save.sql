USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Seminar].[Schedule->Type_Template@Save]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Seminar].[Schedule->Type_Template@Save]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Seminar].[Schedule->Type_Template@Save]
    @Type_Id        SmallInt,
    @Template_Id    SmallInt,
    @Date           SmallDateTime,
    @Data           VarChar(Max)
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

        UPDATE [Seminar].[Schedules->Types:Templates] SET
            [Data] = @Data
        WHERE   [Type_Id]       = @Type_Id
            AND [Template_Id]   = @Template_Id
            AND [Date]          = @Date;

        IF @@RowCount = 0
            INSERT INTO [Seminar].[Schedules->Types:Templates]([Type_Id], [Template_Id], [Date], [Data])
            VALUES (@Type_Id, @Template_Id, @Date, @Data);

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
