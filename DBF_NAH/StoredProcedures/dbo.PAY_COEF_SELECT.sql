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

ALTER PROCEDURE [dbo].[PAY_COEF_SELECT]
	@active BIT = NULL
AS

BEGIN
	SET NOCOUNT ON

	SELECT PC_START, PC_END, PC_VALUE, PC_ID
	FROM dbo.PayCoefTable
	WHERE PC_ACTIVE = ISNULL(@active, PC_ACTIVE)
	ORDER BY PC_START

	SET NOCOUNT OFF
END

GO
GRANT EXECUTE ON [dbo].[PAY_COEF_SELECT] TO rl_pay_coef_r;
GO