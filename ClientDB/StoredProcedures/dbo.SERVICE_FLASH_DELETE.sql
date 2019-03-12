USE [ClientDB]
	GO
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	CREATE PROCEDURE [dbo].[SERVICE_FLASH_DELETE]	
    @FLASHID VARCHAR(1023)
AS
BEGIN
	SET NOCOUNT ON;
   
    DELETE FROM dbo.ServiceFlashTable
    WHERE ID_FLASH=@FLASHID

END