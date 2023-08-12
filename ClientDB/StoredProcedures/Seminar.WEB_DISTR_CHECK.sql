USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Seminar].[WEB_DISTR_CHECK]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Seminar].[WEB_DISTR_CHECK]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [Seminar].[WEB_DISTR_CHECK]
    @ID             UniqueIdentifier,
    @STR            NVarChar(64),
    @MSG            NVarChar(256) OUTPUT,
    @STATUS         SmallInt OUTPUT,
    @HOST           Int = NULL OUTPUT,
    @DISTR          Int = NULL OUTPUT,
    @COMP           TinyInt = NULL OUTPUT,
    @CLIENT         Int = NULL OUTPUT,
    @SubhostName    VarChar(20) = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

    BEGIN TRY

        DECLARE
            @DS_REG         SmallInt,
            @Subhost_Id     UniqueIdentifier,
            @ERROR          Bit,
            @DISTR_S        NVarChar(64),
            @COMP_S         NVarChar(64);

        SET @STR = LTRIM(RTRIM(@STR));

        IF CHARINDEX('/', @STR) <> 0
        BEGIN
            SET @DISTR_S    = LEFT(@STR, CHARINDEX('/', @STR) - 1);
            SET @COMP_S     = RIGHT(@STR, LEN(@STR) - CHARINDEX('/', @STR));
        END
        ELSE
        BEGIN
            SET @DISTR_S = @STR;
            SET @COMP_S = '1';
        END;

        SET @ERROR = 0;

        BEGIN TRY
            SET @DISTR = CONVERT(INT, @DISTR_S)
            SET @COMP = CONVERT(INT, @COMP_S)
        END TRY
        BEGIN CATCH
            SET @ERROR = 1;
        END CATCH;

        IF @ERROR = 1
        BEGIN
            SET @STATUS = 1;
            SET @MSG = 'Неверно указан номер дистрибутива. Он должен быть указан либо в виде числа, либо в виде пары чисел, разделенных символом "/"';

            RETURN;
        END;

        SET @HOST = (SELECT TOP (1) MainHostID FROM dbo.RegNodeMainDistrView WITH(NOEXPAND) WHERE MainDistrNumber = @DISTR AND MainCompNumber = @COMP ORDER BY MainHostID);

        IF @HOST IS NULL
        BEGIN
            SET @STATUS = 1;
            SET @MSG = 'Вы не являетесь клиентом компании "Базис". Запись на семинар недоступна';

            RETURN;
        END;

        SELECT
            @DS_REG         = R.DS_REG,
            @SubhostName    = R.SubhostName,
            @Subhost_Id     = S.SH_ID,
            @CLIENT         = S.SH_ID_CLIENT
        FROM Reg.RegNodeSearchView  AS R WITH(NOEXPAND)
        LEFT JOIN dbo.Subhost       AS S ON R.SubhostName = S.SH_REG
        WHERE   R.HostID = @HOST
            AND R.DistrNumber = @DISTR
            AND R.CompNumber = @COMP;

        -- клиент Базиса
        IF @SubhostName = '' BEGIN
            IF @DS_REG <> 0 BEGIN
                SET @STATUS = 1;
                SET @MSG = 'Вы не являетесь сопровождаемым клиентом компании "Базис". Для того, чтобы подключиться к сопровождению, обратитесь к нам.';

                RETURN;
            END;

            SET @CLIENT = (SELECT TOP (1) ID_CLIENT FROM dbo.ClientDistrView WITH(NOEXPAND) WHERE HostID = @HOST AND DISTR = @DISTR AND COMP = @COMP);

            IF @CLIENT IS NULL BEGIN
                SET @STATUS = 1;
                SET @MSG = 'Вы не являетесь клиентом компании "Базис". Запись на семинар недоступна';

                RETURN;
            END;

            IF (SELECT IsNull(IsDebtor, 0) FROM dbo.ClientTable WHERE ClientId = @CLIENT) = 1 BEGIN
                SET @STATUS = 1;
                SET @MSG = 'На текущий момент Ваша компания имеет задолженность за сопровождение системы КонсультантПлюс. В связи с этим запись на семинар не предоставляется.';

                RETURN;
            END;

            IF
                (
                    SELECT COUNT(*)
                    FROM Seminar.Personal
                    WHERE ID_SCHEDULE = @ID
                        AND ID_CLIENT = @CLIENT
                        AND STATUS = 1
                ) >=
                (
                    SELECT COUNT(*)
                    FROM dbo.ClientDistrView WITH(NOEXPAND)
                    WHERE ID_CLIENT = @CLIENT
                        -- ToDo злостный хардкод
                        AND HostID = 1
                        AND DS_REG = 0
                )
            BEGIN
                SET @STATUS = 1;
                SET @MSG = 'Ваш сотрудник уже записан на семинар. Запись невозможна';

                RETURN;
            END
            ELSE
            BEGIN
                SET @STATUS = 0;
            END;
        END ELSE BEGIN
            -- клиент подхоста

            IF @DS_REG <> 0 BEGIN
                SET @STATUS = 1;
                SET @MSG = 'Вы не являетесь сопровождаемым клиентом. Для того, чтобы подключиться к сопровождению, обратитесь к нам.';

                RETURN;
            END;

            IF EXISTS
                (
                    SELECT *
                    FROM Seminar.Personal
                    WHERE ID_SCHEDULE = @ID
                        AND ID_CLIENT = @CLIENT
                        AND [Host_Id] = @HOST
                        AND Distr = @DISTR
                        AND Comp = @COMP
                        AND STATUS = 1
                )
            BEGIN
                SET @STATUS = 1;
                SET @MSG = 'Ваш сотрудник уже записан на семинар. Запись невозможна';

                RETURN;
            END
            ELSE
            BEGIN
                SET @STATUS = 0;
            END
        END

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Seminar].[WEB_DISTR_CHECK] TO rl_seminar_web;
GO
