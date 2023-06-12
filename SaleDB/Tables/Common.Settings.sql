USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Common].[Settings]
(
        [ID]             UniqueIdentifier      NOT NULL,
        [ID_USER]        UniqueIdentifier          NULL,
        [DEFAULT_RUS]    Bit                   NOT NULL,
        [SEARCH_EXT]     Bit                   NOT NULL,
        [MULTY_SEARCH]   Bit                   NOT NULL,
        [WARNING_TIME]   SmallInt              NOT NULL,
        [FONT_SIZE]      SmallInt              NOT NULL,
        [OFFER_PATH]     NVarChar(1024)            NULL,
        [LAST]           DateTime              NOT NULL,
        CONSTRAINT [PK_Common.Settings] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_Common.Settings(ID_USER)_Common.Users(ID)] FOREIGN KEY  ([ID_USER]) REFERENCES [Security].[Users] ([ID])
);
GO
CREATE NONCLUSTERED INDEX [IX_Common.Settings(LAST)] ON [Common].[Settings] ([LAST] ASC);
GO
