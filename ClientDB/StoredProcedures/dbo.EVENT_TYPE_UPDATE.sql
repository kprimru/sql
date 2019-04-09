USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[EVENT_TYPE_UPDATE]
	@ID	INT,
	@NAME	VARCHAR(50),
	@REPORT	BIT,
	@HIDE	BIT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.EventTypeTable
	SET EventTypeName = @NAME,
		EventTypeReport = @REPORT,
		EventTypeHide = @HIDE,
		EventTypeLast = GETDATE()
	WHERE EventTypeID = @ID
END