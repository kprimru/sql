USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Queue].[Online Password@Process]
    @Id             Int,
    @Login          VarChar(100),
    @Password       VarChar(100)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    DECLARE
        @EmailRecipients    VarChar(Max),
        @EmailSubject       VarChar(Max),
        @EmailBody          VarChar(Max),
        @DistrTypeCode      VarChar(100),
        @DistrTypeShort     VarChar(100),
        @NetTypeShort       VarChar(100),
        @DistrStr           VarChar(128),
        @Comment            VarChar(256),
        @DistrNumber        Int,
        @CompNumber         TinyInt,
        @Subhost_Id         UniqueIdentifier;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

    BEGIN TRY
        BEGIN TRAN;

        UPDATE [Queue].[Online Passwords] SET
            [Login]             = @Login,
            [Password]          = @Password,
            [ProcessDateTime]   = GetDate()
        WHERE [Id] = @Id

        IF CharIndex('_', @Login) < 1 BEGIN
            SET @DistrNumber = @Login;
            SET @CompNumber = 1;
        END ELSE BEGIN
            SET @CompNumber = Right(@Login, CharIndex('_', Reverse(@Login)) - 1);
            SET @DistrNumber = Left(@Login, CharIndex('_', @Login) - 1);
        END;

        SELECT
            @DistrTypeCode  = DistrType,
            @DistrTypeShort = SST_SHORT,
            @NetTypeShort   = NT_SHORT,
            @DistrStr       = DistrStr,
            @Comment        = Comment
        FROM [Reg].[RegNodeSearchView] AS R WITH(NOEXPAND)
        WHERE [DistrNumber] = @DistrNumber
            AND [CompNumber] = @CompNumber
            AND [HostID] = 1;

        -- ToDo именованные множества
        IF @DistrTypeCode = 'NEK' BEGIN
            SELECT @Subhost_Id = SC_ID_SUBHOST
            FROM dbo.SubhostComplect AS SC
            WHERE SC.SC_ID_HOST = 1
                AND SC.SC_DISTR = @DistrNumber
                AND SC.SC_COMP = @CompNumber;

            IF @Subhost_Id IS NULL
                SELECT @Subhost_Id = SH_ID
                FROM dbo.Subhost
                WHERE SH_REG = '';

            SELECT @EmailRecipients = SH_ODD_EMAIL
            FROM dbo.Subhost
            WHERE SH_ID = @Subhost_Id;

            SET @EmailRecipients    = 'urazova@bazis;nalunina@bazis';
            SET @EmailSubject       = @Login + ' ' + IsNull(@NetTypeShort, '') + ' - параметры доступа';
            SET @EmailBody          = '<table bgcolor="#ffffff">
    <tr>
        <td width=800>
            <span style=" font-family:''verdana''; font-size: 14pt; color: #514da1;">
                <b>
                    Онлайн-версия систем КонсультантПлюс
                    <br>
                    <br>
                    <br>
                </b>
            </span>
            <table border=2 bordercolor="#5e67a8" bgcolor="#f1f2f7">
                <tr>
                    <td width=756>
                        <span style=" font-family:''courier new''; font-size: 12pt;">
                            <b>Данные для доступа к Системе:
                                <br>
                            </b>
                            <span style=" font-size: 9pt;">Ссылка:</span>
                        </span>
                        <a style=" font-family:''courier new''; font-size: 12pt;" href="https://login.consultant.ru/">https://login.consultant.ru/</a>
                        <br>
                            <span style=" font-family:''courier new''; font-size: 9pt;">Логин: ' + @Login + '
                        <br>Пароль: ' + @Password + '
                    </td>
                </tr>
            </table>'
        END ELSE IF @DistrTypeCode IS NULL BEGIN
            SET @EmailRecipients    = 'denisov@bazis;blohin@bazis;gvv@bazis';
            SET @EmailSubject       = @Login + ' ' + IsNull(@NetTypeShort, '') + ' - параметры доступа';
            SET @EmailBody          = 'Внимание! Дистрибутив не найден в РЦ!' + Char(13) + Char(10) + 'Получены учетные данные для дистрибутива ' + @Login + Char(13) + Char(10) + 'Пароль: ' + @Password;
            SET @EmailBody          = '<table bgcolor="#ffffff">
    <tr>
        <td width=800>
            <span style=" font-family:''verdana''; font-size: 14pt; color: #514da1;">
                <b>
                    Получены учетные данные для дистрибутива
                    <br>
                    Внимание! Дистрибутив не найден в РЦ!
                    <br>
                    <br>
                    <br>
                </b>
            </span>
            <table border=2 bordercolor="#5e67a8" bgcolor="#f1f2f7">
                <tr>
                    <td width=756>
                        <span style=" font-family:''courier new''; font-size: 12pt;">
                            <b>Данные для доступа к Системе:
                                <br>
                            </b>
                            <span style=" font-size: 9pt;">Ссылка:</span>
                        </span>
                        <a style=" font-family:''courier new''; font-size: 12pt;" href="https://login.consultant.ru/">https://login.consultant.ru/</a>
                        <br>
                            <span style=" font-family:''courier new''; font-size: 9pt;">Логин: ' + @Login + '
                        <br>Пароль: ' + @Password + '
                    </td>
                </tr>
            </table>'
        END ELSE BEGIN
            SET @EmailRecipients    = 'blohin@bazis;gvv@bazis';
            SET @EmailSubject       = @Login + ' ' + IsNull(@NetTypeShort, '') + ' - параметры доступа';
            SET @EmailBody          = '<table bgcolor="#ffffff">
    <tr>
        <td width=800>
            <span style=" font-family:''verdana''; font-size: 14pt; color: #514da1;">
                <b>
                    Получены учетные данные для дистрибутива ' + IsNull(@DistrStr, '') + '
                    <br>
                    <br>
                    <br>
                </b>
            </span>
            <table border=2 bordercolor="#5e67a8" bgcolor="#f1f2f7">
                <tr>
                    <td width=756>
                        <span style=" font-family:''courier new''; font-size: 12pt;">
                            <b>Данные для доступа к Системе:
                                <br>
                            </b>
                            <span style=" font-size: 9pt;">Ссылка:</span>
                        </span>
                        <a style=" font-family:''courier new''; font-size: 12pt;" href="https://login.consultant.ru/">https://login.consultant.ru/</a>
                        <br>
                            <span style=" font-family:''courier new''; font-size: 9pt;">Логин: ' + IsNull(@Login, '') + '
                        <br>Пароль: ' + IsNull(@Password, '') + '
                    </td>
                </tr>
            </table>'
        END;

        EXEC [Common].[MAIL_SEND]
            @Recipients     = @EmailRecipients,
            @blind_copy_recipients  = 'denisov@bazis',
            @Subject        = @EmailSubject,
            @Body_Format    = 'HTML',
            @Body           = @EmailBody;

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;

        IF @@TranCount > 0
            COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TranCount > 0
            ROLLBACK TRAN;

        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
