USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 25.08.2008
��������:	  ������� �� ����������� ���������
               � ��������� �����
*/

ALTER PROCEDURE [dbo].[POSITION_DELETE]
	@positionid INT
AS
BEGIN
	SET NOCOUNT ON

	DELETE
	FROM dbo.PositionTable
	WHERE POS_ID = @positionid

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[POSITION_DELETE] TO rl_position_d;
GO