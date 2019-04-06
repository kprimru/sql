USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[TO_PERSONAL_DEFAULT]
	@ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @RP	INT
	DECLARE @RP_NAME VARCHAR(100)
	
	SELECT TOP 1 @RP = RP_ID, @RP_NAME = RP_NAME
	FROM dbo.ReportPositionTable
	WHERE RP_ACTIVE = 1
		AND NOT EXISTS
			(
				SELECT *
				FROM dbo.TOPersonalTable
				WHERE TP_ID_RP = RP_ID
					AND TP_ID_TO = @ID
			)
	ORDER BY RP_ID

	SELECT 
		'' AS TP_SURNAME, '' AS TP_NAME, '' AS TP_OTCH, '8(423)' AS TP_PHONE,
		@RP AS RP_ID, @RP_NAME AS RP_NAME
END
