USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
��������:	  ������� ������� � ����������� ��������� ��.
*/

ALTER PROCEDURE [dbo].[TO_ADDRESS_GET]
	@taid INT
AS
BEGIN
	SET NOCOUNT ON

	SELECT
			TA_ID, TA_INDEX, TA_HOME, ST_ID, ST_NAME
	FROM dbo.TOAddressView
	WHERE TA_ID = @taid

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[TO_ADDRESS_GET] TO rl_client_r;
GO