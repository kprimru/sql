USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
�����:		  ������� �������
���� ��������: 25.08.2008
��������:	  �������� ������ � ��������� � ��������� �����
*/

ALTER PROCEDURE [dbo].[POSITION_EDIT]
	@positionid INT,
	@positionname VARCHAR(150),
	@positionactive BIT
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.PositionTable
	SET POS_NAME = @positionname ,
		POS_ACTIVE = @positionactive
	WHERE POS_ID = @positionid

	SET NOCOUNT OFF
END

GO
GRANT EXECUTE ON [dbo].[POSITION_EDIT] TO rl_position_w;
GO