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

CREATE PROCEDURE [dbo].[GLOBAL_SETTINGS_DELETE]
	@gsid SMALLINT
AS
BEGIN	
	SET NOCOUNT ON;

	DELETE
	FROM dbo.GlobalSettingsTable
	WHERE GS_ID = @gsid
END

