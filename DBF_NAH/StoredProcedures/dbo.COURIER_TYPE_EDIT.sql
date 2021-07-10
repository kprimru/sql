USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
��������:
*/

ALTER PROCEDURE [dbo].[COURIER_TYPE_EDIT]
	@id SMALLINT,
	@name VARCHAR(100),
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.CourierTypeTable
	SET COT_NAME = @name,
		COT_ACTIVE = @active
	WHERE COT_ID = @id

	SET NOCOUNT OFF
END

GO
GRANT EXECUTE ON [dbo].[COURIER_TYPE_EDIT] TO rl_courier_type_w;
GO