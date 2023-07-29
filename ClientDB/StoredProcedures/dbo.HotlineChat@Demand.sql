USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[HotlineChat@Demand]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[HotlineChat@Demand]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[HotlineChat@Demand]
	@Hotline_Id		UniqueIdentifier,
	@Demands		NVarChar(Max)
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

		IF NOT EXISTS(SELECT * FROM [dbo].[HotlineChat=Process] WHERE [Hotline_Id] = @Hotline_Id)
			INSERT INTO [dbo].[HotlineChat=Process]([Hotline_Id])
			VALUES (@Hotline_Id);

		DELETE FROM [dbo].[HotlineChat:Demand] WHERE [HotlineChat_Id] = @Hotline_Id;

		INSERT INTO [dbo].[HotlineChat:Demand]([HotlineChat_Id], [Demand_Id])
		SELECT @Hotline_Id, I.[ID]
		FROM [dbo].[TableIDFromXML](@Demands) AS I;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END

GO
