USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 19.11.2008
��������:	  ���������� 0, ���� ������� �����
                ������� �� ����������� (�� �
               ����� ������� �� �� ������),
               -1 � ��������� ������
*/

ALTER PROCEDURE [dbo].[SYSTEM_NET_COEF_TRY_DELETE]
	@swid INT
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @res INT
	DECLARE @txt VARCHAR(MAX)

	SET @res = 0
	SET @txt = ''


	SELECT @res AS RES, @txt AS TXT

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[SYSTEM_NET_COEF_TRY_DELETE] TO rl_system_net_w;
GO