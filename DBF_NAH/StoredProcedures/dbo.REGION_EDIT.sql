USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 25.08.2008
��������:	  �������� ������ � ������� �
               ��������� �����
*/

ALTER PROCEDURE [dbo].[REGION_EDIT]
	@regionid SMALLINT,
	@regionname VARCHAR(100),
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.RegionTable
	SET RG_NAME = @regionname,
		RG_ACTIVE = @active
	WHERE RG_ID = @regionid

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[REGION_EDIT] TO rl_region_w;
GO