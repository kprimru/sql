USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CLIENT_TYPE_UPDATE]
	@ID	INT,
	@NAME	VARCHAR(100),
	@DAY	INT,
	@DAILY	INT,
	@PAPPER	SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE dbo.ClientTypeTable
	SET ClientTypeName = @NAME,
		ClientTypeDailyDay = @DAILY,
		ClientTypeDay = @DAY,
		ClientTypePapper = @PAPPER
	WHERE ClientTypeID = @ID
END