USE [DBF_NAH]
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

ALTER PROCEDURE [dbo].[GLOBAL_SETTINGS_DELETE]
	@gsid SMALLINT
AS
BEGIN
	SET NOCOUNT ON;

	DELETE
	FROM dbo.GlobalSettingsTable
	WHERE GS_ID = @gsid
END


GO
GRANT EXECUTE ON [dbo].[GLOBAL_SETTINGS_DELETE] TO rl_global_settings_d;
GO