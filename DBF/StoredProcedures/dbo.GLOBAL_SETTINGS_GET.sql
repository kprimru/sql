USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
�����:			������� �������/������ ��������
���� ��������:  	
��������:		
*/

CREATE PROCEDURE [dbo].[GLOBAL_SETTINGS_GET]
	@gsid SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT GS_NAME, GS_VALUE, GS_ACTIVE
	FROM dbo.GlobalSettingsTable
	WHERE GS_ID = @gsid
END


