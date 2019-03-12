USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[EVENT_TYPE_DELETE]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	DELETE
	FROM dbo.EventTypeTable
	WHERE EventTypeID = @ID
END