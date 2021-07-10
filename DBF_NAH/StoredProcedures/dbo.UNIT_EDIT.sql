USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
�����:		  ������� �������
���� ��������: 24.09.2008
��������:	  �������� ������ � ���� ������� �
               ��������� ����� � �����������
*/

ALTER PROCEDURE [dbo].[UNIT_EDIT]
	@unitid SMALLINT,
	@name VARCHAR(100),
	@okei VARCHAR(50),
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.UnitTable
	SET UN_NAME = @name,
		UN_OKEI = @okei,
		UN_ACTIVE = @active
	WHERE UN_ID = @unitid

	SET NOCOUNT OFF
END

GO
GRANT EXECUTE ON [dbo].[UNIT_EDIT] TO rl_unit_w;
GO