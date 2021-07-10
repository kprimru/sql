USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:			������� �������/������ ��������
���� ��������:  
��������:
*/

ALTER PROCEDURE [dbo].[SALE_OBJECT_ADD]
	@soname VARCHAR(50),
	@taxid SMALLINT,
	--@sobill VARCHAR(50),
	--@soinvunit VARCHAR(50),
	--@sookei VARCHAR(20),
	@active BIT = 1,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO dbo.SaleObjectTable
			(
				SO_NAME, SO_ID_TAX, SO_INV_UNIT, SO_OKEI, SO_ACTIVE
			)
	VALUES
			(
				@soname, @taxid, null, null, @active
			)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN
END






GO
GRANT EXECUTE ON [dbo].[SALE_OBJECT_ADD] TO rl_sale_object_w;
GO