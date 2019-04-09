USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Report].[SUBHOST_STT]
	@PARAM	NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		SH_NAME AS [�������], DATE AS [���� ��������], USR AS [������������], 
		dbo.FileByteSizeToStr(DATALENGTH(BIN)) AS [������], 
		PROCESS AS [���� ���������]
	FROM 
		Subhost.STTFiles a
		INNER JOIN dbo.Subhost b ON SH_ID = ID_SUBHOST
	ORDER BY DATE DESC
END
