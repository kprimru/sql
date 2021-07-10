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

ALTER PROCEDURE [dbo].[DISTR_EDIT]
	@distrid INT,
	@systemid INT,
	@distrnum INT,
	@compnum TINYINT,
	@active BIT = 1
AS
BEGIN
	SET NOCOUNT ON

	UPDATE dbo.DistrTable
	SET DIS_ID_SYSTEM = @systemid,
		DIS_NUM = @distrnum,
		DIS_COMP_NUM = @compnum,
		DIS_ACTIVE = @active
	WHERE DIS_ID = @distrid

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE ON [dbo].[DISTR_EDIT] TO rl_distr_w;
GO