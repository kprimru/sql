USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Debug].[Execution@Finish]
	@DebugContext	Xml,
	@Error			VarChar(512)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@Id				BigInt,
		@FinishDateTime	DateTime;
	
	SET @Id				= @DebugContext.value('(/DEBUG/@Id)[1]', 'BigInt');
	SET @FinishDateTime	= GetDate();
	
	
	INSERT INTO [Debug].[Executions:Fiinsh]([Id], [FinishDateTime], [Error])
	VALUES(@Id, @FinishDateTime, @Error);
END;
