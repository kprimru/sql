USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 25.08.2008
��������:	  �������� ������ � ����������
*/

ALTER PROCEDURE [dbo].[REGION_ADD]
	@regionname VARCHAR(100),
	@active BIT = 1,
	@oldcode INT = NULL,
	@returnvalue BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO dbo.RegionTable(RG_NAME, RG_ACTIVE, RG_OLD_CODE)
	VALUES (@regionname, @active, @oldcode)

	IF @returnvalue = 1
		SELECT SCOPE_IDENTITY() AS NEW_IDEN

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[REGION_ADD] TO rl_region_w;
GO