USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CALENDAR_WORK_ARCH]
	@ID	UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO dbo.CalendarDate(ID_MASTER, DATE, ID_TYPE, NAME, NOTE, STATUS, UPD_DATE, UPD_USER)
		SELECT ID, DATE, ID_TYPE, NAME, NOTE, 2, UPD_DATE, UPD_USER
		FROM dbo.CalendarDate
		WHERE ID = @ID
END
