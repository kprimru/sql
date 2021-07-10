USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
�����:		  ������� �������
���� ��������: 25.08.2008
��������:	  ���������� 0, ���� ������ �����
               ������� �� ����������� (�� ����
               �� ��������� �� ���� ������
               �� ������ ������),
               -1 � ��������� ������
*/

ALTER PROCEDURE [dbo].[QUARTER_TRY_DELETE]
	@periodid SMALLINT
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
GRANT EXECUTE ON [dbo].[QUARTER_TRY_DELETE] TO rl_quarter_d;
GO