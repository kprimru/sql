USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 24.09.2008
��������:	  ������� ��� ������� � ���������
               ����� �� �����������
*/

ALTER PROCEDURE [dbo].[TECHNOL_TYPE_DELETE]
	@technoltypeid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE
	FROM dbo.TechnolTypeTable
	WHERE TT_ID = @technoltypeid

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[TECHNOL_TYPE_DELETE] TO rl_technol_type_d;
GO