USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
�����:		  ������� �������
���� ��������: 18.12.2008
��������:	  ������� ��������������� �������
               � ��������� ����� �� �����������
*/

ALTER PROCEDURE [dbo].[UNIT_DELETE]
	@unitid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE
	FROM dbo.UnitTable
	WHERE UN_ID = @unitid

	SET NOCOUNT OFF
END

GO
GRANT EXECUTE ON [dbo].[UNIT_DELETE] TO rl_unit_d;
GO