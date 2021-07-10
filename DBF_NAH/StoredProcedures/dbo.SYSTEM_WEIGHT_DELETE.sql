USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
���� ��������: 06.11.2008
��������:	  ������� �������� �����
                �������� ����������
*/

ALTER PROCEDURE [dbo].[SYSTEM_WEIGHT_DELETE]
	@swid INT
AS
BEGIN
	SET NOCOUNT ON

	DELETE FROM dbo.SystemWeightTable
	WHERE SW_ID = @swid

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[SYSTEM_WEIGHT_DELETE] TO rl_system_weight_d;
GO