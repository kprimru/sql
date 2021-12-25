USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Debug].[Execution@Finish]
	@DebugContext	Xml,
	@Error			VarChar(512)
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@Id				BigInt,
		@FinishDateTime	DateTime;

	SET @Id				= @DebugContext.value('(/DEBUG/@Id)[1]', 'BigInt');
	SET @FinishDateTime	= GetDate();

	IF @Id IS NOT NULL
		INSERT INTO [Debug].[Executions:Finish]([Id], [FinishDateTime], [Error])
		VALUES(@Id, @FinishDateTime, @Error);
END;

GO
