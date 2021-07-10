USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
�����:			������� �������
��������:
*/

ALTER PROCEDURE [dbo].[GLOBAL_SETTINGS_ADD]
	-- ������ ���������� ���������
	@gsname VARCHAR(50),
	@gsvalue VARCHAR(50),
	@active BIT = 1,
	@returnvalue BIT = 1
AS
BEGIN
	-- SET NOCOUNT ON ���������� ��� ������������� � �������� ����������.
	-- ��������� �������� ������ ���������� � �������� ��������.

	SET NOCOUNT ON;

	-- ����� ��������� ����
	INSERT INTO dbo.GlobalSettingsTable
							(
								GS_NAME, GS_VALUE, GS_ACTIVE
							)
	VALUES
							(
								@gsname, @gsvalue, @active
							)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN
END



GO
GRANT EXECUTE ON [dbo].[GLOBAL_SETTINGS_ADD] TO rl_global_settings_w;
GO