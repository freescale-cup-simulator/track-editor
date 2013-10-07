#ifndef GRID_OPERATOR_H
#define GRID_OPERATOR_H

#include <QObject>
#include <QMap>
#include <QQuickItem>
#include <QUrl>
#include <QtDebug>

#include <track_model.h>
#include <track_io.h>

namespace tl = track_library;

class GridOperator : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int gridWidth READ gridWidth WRITE setGridWidth
               NOTIFY gridDimensionChanged)
    Q_PROPERTY(int gridHeight READ gridHeight WRITE setGridHeight
               NOTIFY gridDimensionChanged)
    Q_PROPERTY(int tileSide READ tileSide CONSTANT)
    Q_PROPERTY(QQuickItem * grid READ grid WRITE setGrid NOTIFY gridChanged)
public:
    GridOperator(QObject * parent = nullptr);

    int gridWidth();
    void setGridWidth(int w);
    int gridHeight();
    void setGridHeight(int h);
    int tileSide();
    QQuickItem *grid();
    void setGrid(QQuickItem * grid);
private:
    tl::Tile::Type stringToType(const QString & string);
    QString typeToString(tl::Tile::Type type);

    QMap<QString, tl::Tile::Type> typeStringMap;
    int m_grid_width;
    int m_grid_height;
    int m_tile_side;
    QQuickItem * m_grid;
public slots:
    void saveGrid(const QUrl & url);
    void loadGrid(const QUrl & url);
signals:
    void placeTile(int x, int y, int rotation, const QString & type);
    void gridDimensionChanged();
    void gridChanged();
};

#endif
