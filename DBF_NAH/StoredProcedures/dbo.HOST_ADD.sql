USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 18.11.2008
��������:	  �������� ����
               � ����������
*/

ALTER PROCEDURE [dbo].[HOST_ADD]
	@hostname VARCHAR(250),
	@hostregname VARCHAR(20),
	@active BIT = 1,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.HostTable(HST_NAME, HST_REG_NAME, HST_ACTIVE)
	VALUES (@hostname, @hostregname, @active)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[HOST_ADD] TO rl_host_w;
GO