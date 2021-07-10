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

ALTER PROCEDURE [dbo].[DISTR_SELECT]
	@active BIT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT DIS_ID, DIS_STR, SYS_SHORT_NAME, DIS_NUM, DIS_COMP_NUM
	FROM dbo.DistrView WITH(NOEXPAND)
	WHERE DIS_ACTIVE = ISNULL(@active, DIS_ACTIVE)
	ORDER BY SYS_ORDER, DIS_NUM, DIS_COMP_NUM

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[DISTR_SELECT] TO rl_distr_r;
GO